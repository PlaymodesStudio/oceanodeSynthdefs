(
~synthCreator.value("Snare", {|n|
	var pop, popAmp, popFreq, noise, noiseAmp, snd;

	// Parameters exactly matching the original
	var gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	var hif = OceanodeParameter.ar(\hifreq, 2810, n, 1000, 5000, "vf");
	var hirel = OceanodeParameter.ar(\hirel, 0.725, n, 0.1, 2, "vf");
	var poprel = OceanodeParameter.ar(\poprel, 0.11, n, 0.01, 1, "vf");
	var poplevel = OceanodeParameter.ar(\poplevel, 0.7, n, 0, 1, "vf");
	var noiselevel = OceanodeParameter.ar(\noiselevel, 1, n, 0, 2, "vf");
	var poppitch = OceanodeParameter.ar(\poppitch, 58, n, 24, 96, "vf");
	var pophi = OceanodeParameter.ar(\pophi, 3261, n, 1000, 5000, "vf");
	var amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);

	// Convert MIDI to frequency
	poppitch = poppitch.midicps;

	// Pop component - EXACTLY like the original
	popFreq = EnvGen.ar(Env([pophi, 410, poppitch], [0.005, 0.01], curve: \exp), gate);
	popAmp = EnvGen.ar(Env.perc(0.001, poprel), gate) * poplevel;
	pop = SinOsc.ar(popFreq) * popAmp;

	// Noise component - EXACTLY like the original
	noiseAmp = EnvGen.ar(Env.perc(0.0001, hirel), gate);
	noise = BPF.ar(WhiteNoise.ar, hif, 1.6) * noiseAmp;
	noise = noise * noiselevel;

	// Mix components
	snd = (pop + noise) * amp;

	Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "Snare drum with pop transient and filtered noise", category: "Source/Percussion");
)