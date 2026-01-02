(
~synthCreator.value("FbDroneMod", {|n|
	var snd, winsz, prelpf, rlpfmax, lfo, deltime, rlpfmod, ampmod, psmod, levels;
	var deltimemod, rlpfmod_rate, ampmod_rate, psmod_rate;

	// Parameters
	winsz = OceanodeParameter.ar(\winsz, 0.03, n, 0.001, 0.1, "vf");
	prelpf = OceanodeParameter.ar(\prelpf, 110, n, 20, 135, "vf").midicps;
	rlpfmax = OceanodeParameter.ar(\rlpfmax, 130, n, 20, 135, "vf").midicps;
	
	// Modulation rates
	deltimemod = OceanodeParameter.ar(\deltimemod, 0.5, n, 0.01, 10, "vf");
	rlpfmod_rate = OceanodeParameter.ar(\rlpfmod, 3, n, 0.01, 10, "vf");
	ampmod_rate = OceanodeParameter.ar(\ampmod, 3, n, 0.01, 10, "vf");
	psmod_rate = OceanodeParameter.ar(\psmod, 1, n, 0.01, 10, "vf");
	
	// Output level
	levels = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true);

	// LFO function
	lfo = { |rate|
		Select.ar(
			ToggleFF.ar(Dust.ar(rate)),
			[LFNoise2.ar(rate).clip2, TRand.ar(-1, 1, Dust.ar(rate * 30))]
		);
	};

	// Calculate modulation values
	deltime = lfo.(deltimemod).linlin(-1, 1, 0.0, 0.04) + (lfo.(16 ! 2).linlin(-1, 1, 0.0, 0.001));
	rlpfmod = lfo.(rlpfmod_rate).linexp(-1, 1, 100, rlpfmax);
	ampmod = lfo.(ampmod_rate).linexp(0, 1, 1, 10.dbamp);
	psmod = 2 ** lfo.(psmod_rate);

	// Generate and process sound
	snd = Hasher.ar(Sweep.ar);
	snd = snd + LocalIn.ar(n);
	snd = DelayC.ar(snd, 0.2, deltime);
	snd = LeakDC.ar(snd);
	snd = snd + (snd.reverse * -10.dbamp);
	snd = snd + PitchShift.ar(snd, winsz, psmod);
	snd = LPF.ar(snd, prelpf);
	snd = RLPF.ar(snd, rlpfmod);
	snd = snd * ampmod;
	snd = snd.tanh;
	
	// Feedback loop
	LocalOut.ar(snd);
	
	// Apply level control
	snd = snd * levels;
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "Feedback drone with modulated parameters", category: "Source/Feedback");
)