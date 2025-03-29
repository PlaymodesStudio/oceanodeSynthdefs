(
~synthCreator.value("FbDrone", {|n|
	var snd, deltime, winsize, prelpf, rlpf, preamp, lfo, pratio, levels, psratio;

	// Parameters
	deltime = OceanodeParameterLag.ar(\delpitch, 31, n, 20, 80, "vf", 1/30, true).midicps.reciprocal;
	winsize = OceanodeParameterLag.ar(\winsz, 0.03, n, 0.001, 0.1, "vf", 1/30, true);
	prelpf = OceanodeParameterLag.ar(\prelpf, 110, n, 20, 135, "vf", 1/30, true).midicps;
	rlpf = OceanodeParameterLag.ar(\lpf, 100, n, 20, 135, "vf", 1/30, true).midicps;
	preamp = OceanodeParameterLag.ar(\preamp, 1, n, 0, 2, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true);
	
	// Pitch shift ratio modulation
	psratio = OceanodeParameter.ar(\psratio, 1, n, 0.01, 10, "vf");

	// LFO function
	lfo = { |rate|
		Select.ar(
			ToggleFF.ar(Dust.ar(rate)),
			[LFNoise2.ar(rate).clip2, TRand.ar(-1, 1, Dust.ar(rate * 30))]
		);
	};

	// Calculate pitch shift ratio
	pratio = 2 ** lfo.(psratio);

	// Generate and process sound
	snd = Hasher.ar(Sweep.ar(0, 1)!n);
	snd = snd + LocalIn.ar(n);
	snd = DelayC.ar(snd, 0.2, deltime);
	snd = LeakDC.ar(snd);
	snd = snd + (snd.reverse * -10.dbamp);
	snd = snd + PitchShift.ar(snd, winsize, pratio);
	snd = LPF.ar(snd, prelpf);
	snd = RLPF.ar(snd, rlpf);
	snd = snd * preamp;
	snd = snd.tanh;
	
	// Feedback loop
	LocalOut.ar(snd);
	
	// Apply level control
	snd = snd * levels;
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "Feedback drone with pitch shifting and filtering", category: "feedback");
)