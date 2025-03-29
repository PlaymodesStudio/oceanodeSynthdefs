(
~synthCreator.value("Snare", {|n|
	var pop, popAmp, popFreq, noise, noiseAmp, snd;
	var hif, hirel, poprel, poplevel, noiselevel, poppitch, pophi, t_gate, amp;

	// Using tr prefix for trigger behavior in Oceanode
	// This will make the parameter behave like t_gate
	t_gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	hif = OceanodeParameter.ar(\hifreq, 2810, n, 1000, 5000, "vf");
	hirel = OceanodeParameter.ar(\hirel, 0.725, n, 0.1, 2, "vf");
	poprel = OceanodeParameter.ar(\poprel, 0.11, n, 0.01, 1, "vf");
	poplevel = OceanodeParameter.ar(\poplevel, 0.7, n, 0, 1, "vf");
	noiselevel = OceanodeParameter.ar(\noiselevel, 1, n, 0, 2, "vf");
	poppitch = OceanodeParameter.ar(\poppitch, 58, n, 24, 96, "vf");
	pophi = OceanodeParameter.ar(\pophi, 3261, n, 1000, 5000, "vf");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);

	// Convert MIDI to frequency for pop component
	poppitch = poppitch.midicps;

	// Pop component - exactly like the working example
	popFreq = EnvGen.ar(
		Env([pophi, 410, poppitch], [0.005, 0.01], curve: \exp),
		t_gate
	);

	popAmp = EnvGen.ar(Env.perc(0.001, poprel), t_gate) * poplevel;
	pop = SinOsc.ar(popFreq) * popAmp;

	// Noise component - exactly like the working example
	noiseAmp = EnvGen.ar(Env.perc(0.0001, hirel), t_gate);
	noise = BPF.ar(WhiteNoise.ar, hif, 1.6) * noiseAmp;
	noise = noise * noiselevel;

	// Mix components and apply global amplitude
	snd = (pop + noise) * amp;

	Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "Snare drum with pop transient and filtered noise", category: "Source/Percussion");
)