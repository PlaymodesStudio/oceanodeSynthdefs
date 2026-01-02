(
~synthCreator.value("DualFeedback", {|n|
	var mainFreq, mainFeedback, freq, feedback, width, freqMod, filterFreq, filterQ, levels;
	var mainBufs, secBufs, signals;

	// Use OceanodeParameter.kr to avoid Select.ar() interference but keep Oceanode integration
	mainFreq = OceanodeParameterLag.kr(\mainpitch, 63, n, 0, 127, "vf", 1/30, true).midicps;
	mainFeedback = OceanodeParameterLag.kr(\mainfeed, 1, n, 0, 10, "vf", 1/30, true);
	freq = OceanodeParameterLag.kr(\pitch, 43, n, 0, 127, "vf", 1/30, true).midicps;
	feedback = OceanodeParameterLag.kr(\feed, 1, n, 0, 10, "vf", 1/30, true);
	width = OceanodeParameter.kr(\width, 0, n, 0, 1, "vf");
	freqMod = OceanodeParameter.kr(\freqmod, 500, n, 0, 2000, "vf");
	filterFreq = OceanodeParameterLag.kr(\lpf, 95, n, 0, 127, "vf", 1/30, true).midicps;
	filterQ = OceanodeParameter.kr(\q, 1, n, 0.1, 4, "vf");
	levels = OceanodeParameterLag.kr(\levels, 0.2, n, 0, 1, "vf", 1/30, true);

	// Create individual LocalBuf for each channel (exactly like original)
	mainBufs = n.collect { LocalBuf(1).clear };
	secBufs = n.collect { LocalBuf(1, 2).clear };

	// Individual processing for each channel (exactly like original)
	signals = n.collect { |chan|
		var w, mainOsc, mainSnd, secOsc, secSnd;

		// Width array for this channel (exactly like original)
		w = [0, width[chan] * 2pi];

		// Main oscillator with feedback (exactly like original)
		mainOsc = sin(
			LFSaw.ar(mainFreq[chan]).range(0, 2pi) +
			(Dbufrd(mainBufs[chan]) * mainFeedback[chan])
		);
		mainSnd = Duty.ar(SampleDur.ir, 0, Dbufwr(mainOsc, mainBufs[chan]));

		// Secondary oscillator with feedback (exactly like original)
		secOsc = sin(
			LFSaw.ar(freq[chan] + (mainSnd * freqMod[chan])).range(0, 2pi) +
			(Dbufrd(secBufs[chan]) * feedback[chan]) +
			w
		);
		secSnd = Duty.ar(SampleDur.ir, 0, Dbufwr(secOsc, secBufs[chan]));

		// Filter and output (exactly like original)
		DFM1.ar(secSnd, filterFreq[chan], filterQ[chan]) * levels[chan];
	};

	Out.ar(OceanodeOutput.kr(\out), signals);

}, description: "Dual feedback oscillator with frequency modulation and filtering", category: "Source/Feedback");
)