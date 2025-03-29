(
~synthCreator.value("GranularReverb", {|n|
	var input, grained, readPos, writePos, signal;
	var tFreqMod, rateMod, offsetMod;
	var t, bufFrames;

	// Main parameters with lag for smooth transitions
	var tFreq = OceanodeParameterLag.ar(\tfreq, 26.6, n, 1, 400, "vf", 1/30, true);
	var overlap = OceanodeParameterLag.ar(\overlap, 5.3, n, 0.01, 100, "vf", 1/30, true);
	var offset = OceanodeParameterLag.ar(\offset, 0.031, n, 0, 1, "vf", 1/30, true);
	var rate = OceanodeParameterLag.ar(\rate, 1.0, n, -2, 2, "vf", 1/30, true);
	var feedback = OceanodeParameterLag.ar(\feedback, 0.44, n, 0, 2, "vf", 1/30, true);

	// Modulation parameters
	var tFreqMF = OceanodeParameter.ar(\tfreqmf, 25.0, n, 0, 200, "vf");
	var tFreqMD = OceanodeParameter.ar(\tfreqmd, 0.0, n, 0, 200, "vf");
	var rateMF = OceanodeParameter.ar(\ratemf, 19.8, n, 0, 200, "vf");
	var rateMD = OceanodeParameter.ar(\ratemd, 0.0, n, 0, 1, "vf");
	var offsetMF = OceanodeParameter.ar(\offsetmf, 94.0, n, 0, 10000, "vf");
	var offsetMD = OceanodeParameter.ar(\offsetmd, 0.106, n, 0, 1, "vf");

	// Filter parameters
	var hpf = OceanodeParameter.ar(\hpf, 93, n, 20, 5000, "vf");
	var lpf = OceanodeParameter.ar(\lpf, 14394, n, 200, 20000, "vf");

	// Dry/wet mix control - converted from separate wet/dry to a single mix parameter
	// The original had wet=0.5, dry=1.0 which would be biased toward dry
	var mix = OceanodeParameterLag.ar(\mix, -0.3, n, -1, 1, "vf", 1/30, true);

	// Get input from bus
	input = In.ar(OceanodeInput.kr(\in), n);

	// Buffer size for each channel - using large buffer for longer reverb possibilities
	bufFrames = 2**18;

	// Process each channel independently
	grained = n.collect { |i|
		var buf, chan_input, chan_grained;

		// Create local buffer for each channel
		buf = LocalBuf(bufFrames).clear;

		// Get individual channel input
		chan_input = input[i];

		// Generate modulation for this channel
		tFreqMod = SinOsc.ar(tFreqMF[i], Rand(0.0, 2pi)) * tFreqMD[i];
		rateMod = SinOsc.ar(rateMF[i], Rand(0.0, 2pi)) * rateMD[i];
		offsetMod = SinOsc.ar(offsetMF[i], Rand(0.0, 2pi)) * offsetMD[i];

		// Position phasors for this channel
		writePos = Phasor.ar(0, 1, 0, bufFrames);

		// Trigger signal for grains
		t = Impulse.ar(tFreq[i] + tFreqMod);

		// Calculate read position with offset and modulation
		readPos = ((writePos - 64) / bufFrames) - offset[i] - offsetMod;
		readPos = Wrap.ar(readPos, 0, 1);

		// Generate granular processed signal for this channel
		chan_grained = GrainBufJ.ar(
			numChannels: 1,
			trigger: t,
			dur: overlap[i] / (tFreq[i] + tFreqMod),
			sndbuf: buf,
			rate: rate[i] - rateMod,
			pos: readPos,
			interp: 4,
			pan: 0,
			envbufnum: -1,
			maxGrains: 512,
			loop: 1
		);

		// Apply filters
		chan_grained = HPF.ar(chan_grained, hpf[i]);
		chan_grained = LPF.ar(chan_grained, lpf[i]);

		// Write to buffer with feedback
		BufWr.ar(
			chan_grained * feedback[i] + chan_input,
			buf,
			writePos
		);

		// Return the processed channel
		chan_grained;
	};

	// Mix dry and wet signals using XFade2 for each channel
	signal = n.collect { |i|
		XFade2.ar(input[i], grained[i], mix[i]);
	};

	// Output processed signal
	Out.ar(OceanodeOutput.kr(\out), signal);

}, description: "Granular reverb effect with independent multi-channel processing", category: "Effect/Time/Reverb");
)