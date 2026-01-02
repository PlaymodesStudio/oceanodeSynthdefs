(
~synthCreator.value("Clap", {|n|
	var env1, env2, snd, noise1, noise2, gate, rel, att, hif, lof, midf, popamp, tailamp, pophi, popmid, amp, trig;

	// Parameters with appropriate ranges - all are arrays with n elements
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	rel = OceanodeParameter.ar(\release, 0.5, n, 0.1, 2, "vf");
	att = OceanodeParameter.ar(\attack, 0.02, n, 0.001, 0.1, "vf");
	hif = OceanodeParameter.kr(\hifreq, 1000, n, 200, 5000, "vf");
	lof = OceanodeParameter.kr(\lofreq, 7000, n, 1000, 10000, "vf");
	midf = OceanodeParameter.kr(\midfreq, 1330, n, 500, 3000, "vf");
	popamp = OceanodeParameter.ar(\popamp, 1, n, 0, 2, "vf");
	tailamp = OceanodeParameter.ar(\tailamp, 1, n, 0, 2, "vf");
	pophi = OceanodeParameter.kr(\pophi, 600, n, 100, 2000, "vf");
	popmid = OceanodeParameter.kr(\popmid, 1620, n, 500, 3000, "vf");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf");

	// Create trigger signals from gate - element-wise
	 trig = Trig.ar(gate);

	// Process each channel independently using multichannel expansion

	// Noise 1 - 4 short repeats (separate envelope for each channel)
	env1 = EnvGen.ar(
		Env.new(
			[0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
			[0.001, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
			[0, -3, 0, -3, 0, -3, 0, -4]
		),
		trig
	);

	// Using multichannel expansion to create independent noise for each channel
	noise1 = WhiteNoise.ar(0.2) * env1;
	noise1 = HPF.ar(noise1, pophi);
	noise1 = LPF.ar(noise1, XLine.kr(7200, 4000, 0.03));
	noise1 = BPF.ar(noise1, popmid, 3);
	noise1 = noise1 * popamp;

	// Noise 2 - 1 longer single (separate envelope for each channel)
	env2 = EnvGen.ar(Env.new([0, 1, 0], [att, rel], [0, -4]), trig);

	// Using multichannel expansion for second noise component
	noise2 = WhiteNoise.ar(0.2) * env2;
	noise2 = HPF.ar(noise2, hif);
	noise2 = LPF.ar(noise2, lof);
	noise2 = BPF.ar(noise2, midf, 0.7, 0.7);
	noise2 = noise2 * tailamp;

	// Mix and process
	snd = noise1 + noise2;
	snd = snd * 2 * amp;
	snd = snd.softclip;

	Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "Clap sound with separate pop and tail components", category: "Source/Percussion");
)