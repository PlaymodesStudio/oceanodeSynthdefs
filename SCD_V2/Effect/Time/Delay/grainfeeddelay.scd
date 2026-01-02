(
~synthCreator.value("GrainFeedDelay", {|n|
	var bufferSize = 5;
	var amp, delayTime, delayJitter, trigRate, grainDur, grainDurJitter, rate, dryWet, send;
	var feedback, feedbackFilter, resonance, periodicity, reset;
	var grainAmp, grainAmpJitter, grainReverseProb;
	var input, circularBuf, writePos, readPos;
	var granulation, delayedSig, outputSig, feedbackSig;
	var bufFrames, grainTrig, envBuf;

	// Parameters
	amp = OceanodeParameter.ar(\levels, 1, n, 0, 1, "vf");
	delayTime = OceanodeParameter.ar(\delay, 1, n, 0.1, 5, "vf");
	delayJitter = OceanodeParameter.ar(\delay_jit, 0.1, n, 0, 1, "vf");
	trigRate = OceanodeParameter.ar(\trighz, 10, n, 1, 50, "vf");
	periodicity = OceanodeParameter.ar(\periodicity, 0, n, 0, 1, "vf");
	grainDur = OceanodeParameter.ar(\graindur, 0.35, n, 0.01, 1, "vf");
	grainDurJitter = OceanodeParameter.ar(\graindur_jit, 0, n, 0, 1, "vf");
	grainAmp = OceanodeParameter.ar(\grainamp, 1, n, 0, 1, "vf");
	grainAmpJitter = OceanodeParameter.ar(\grainamp_jit, 0, n, 0, 1, "vf");
	grainReverseProb = OceanodeParameter.ar(\grainrev_prob, 0, n, 0, 1, "vf");
	rate = OceanodeParameter.ar(\pitch, 0, n, -24, 24, "vf").midiratio;
	dryWet = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);
	feedback = OceanodeParameterLag.ar(\feedback, 0.3, n, 0, 0.95, "vf", 1/30, true);
	feedbackFilter = OceanodeParameterLag.ar(\fb_filter, 130, n, 0, 130, "vf", 1/30, true);
	resonance = OceanodeParameterLag.ar(\resonance, 0.2, n, 0, 1, "vf", 1/30, true);
	reset = OceanodeParameterLag.ar(\reset, 0, n, 0, 1, "vi", 1/30, true);
	envBuf = OceanodeBuffer.kr(\envbuf);

	// Allocate buffer within the SynthDef
	circularBuf = LocalBuf(SampleRate.ir * bufferSize, 1).clear;
	bufFrames = BufFrames.kr(circularBuf);

	// Input
	input = In.ar(OceanodeInput.kr(\in), n);

	// Initialize feedback signal
	feedbackSig = LocalIn.ar(n);

	// Process each channel with feedback
	outputSig = n.collect { |i|
		var monoInput = input[i];
		var monoWritePos, monoReadPos, monoGrainTrig;
		var monoGranulation, inputWithFeedback;
		var dustTrig, impulseTrig, actualGrainDur;
		var grainPlayRate, actualGrainAmp, resetTrig;

		// Create reset trigger from parameter changes
		resetTrig = Trig1.kr(reset[i], 0.01);

		// Mix input with filtered feedback
		inputWithFeedback = monoInput + feedbackSig[i];

		// Write position and recording - apply send parameter here
		monoWritePos = Phasor.ar(0, 1, 0, bufFrames);
		BufWr.ar(inputWithFeedback * send[i], circularBuf, monoWritePos);

		// Read position
		monoReadPos = Wrap.ar(monoWritePos - (delayTime[i] * SampleRate.ir), 0, bufFrames);

		// Create both random and periodic triggers
		dustTrig = Dust.kr(trigRate[i]);
		impulseTrig = Impulse.kr(trigRate[i], resetTrig); // Reset impulse phase

		// Crossfade between random and periodic triggering
		monoGrainTrig = XFade2.kr(dustTrig, impulseTrig, periodicity[i] * 2 - 1);

		// Calculate grain duration with jitter
		actualGrainDur = grainDur[i] * (1 + TRand.ar(grainDurJitter[i].neg, grainDurJitter[i], monoGrainTrig));

		// Calculate grain playback rate with reverse probability
		grainPlayRate = rate[i] * Select.kr(
			TRand.kr(0, 1, monoGrainTrig) < grainReverseProb[i],
			[1, -1]  // normal or reversed
		);

		// Calculate grain amplitude with jitter
		actualGrainAmp = grainAmp[i] * (1 + TRand.ar(grainAmpJitter[i].neg, grainAmpJitter[i], monoGrainTrig));

		// Granulation
		monoGranulation = GrainBuf.ar(
			numChannels: 1,
			trigger: monoGrainTrig,
			dur: actualGrainDur,
			sndbuf: circularBuf,
			rate: grainPlayRate,
			pos: (monoReadPos + TRand.ar(0, delayJitter[i] * SampleRate.ir, monoGrainTrig)) / bufFrames,
			interp: 2,
			pan: 0,
			envbufnum: envBuf
		) * actualGrainAmp;

		// Mix dry and wet signals
		XFade2.ar(monoInput, monoGranulation * amp[i], dryWet[i] * 2 - 1);
	};

	// Create filtered feedback signal
	feedbackSig = outputSig.collect { |ch, i|
		var fbSig = ch * feedback[i];
		// Apply feedback filter with resonance
		fbSig = RLPF.ar(fbSig, feedbackFilter[i].midicps, 1 - resonance[i]);
		// Soft limiting to prevent runaway feedback
		fbSig = (fbSig * 0.7).tanh;
		fbSig;
	};

	// Send feedback back to LocalIn
	LocalOut.ar(feedbackSig);

	// Output
	Out.ar(OceanodeOutput.kr(\out), outputSig);
}, description: "Granular cloud delay with feedback filtering and grain control", category: "Effect/Time/Delay");
)

