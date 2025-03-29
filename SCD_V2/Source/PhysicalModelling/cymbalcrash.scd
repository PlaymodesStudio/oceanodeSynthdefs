(
~synthCreator.value("Cymbal", {|n|
	var minFreq, maxFreq, resonNum, locut, hicut, time, thwackLevel, resoLevel, loDriveLevel, att, gate, amp;
	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;
	var maxResonators = 100;

	// Control parameters
	minFreq = OceanodeParameterLag.ar(\minfreq, 300, n, 0, 20000, "vf", 1/30, true);
	maxFreq = OceanodeParameterLag.ar(\maxfreq, 20000, n, 0, 20000, "vf", 1/30, true);
	locut = OceanodeParameterLag.ar(\locut, 20000, n, 0, 20000, "vf", 1/30, true);
	hicut = OceanodeParameterLag.ar(\hicut, 10000, n, 0, 20000, "vf", 1/30, true);
	time = OceanodeParameterLag.ar(\time, 5, n, 0.001, 20, "vf", 1/30, true);
	att = OceanodeParameterLag.ar(\att, 1, n, 1, 10, "vf", 1/30, true);
	thwackLevel = OceanodeParameterLag.ar(\thwacklevel, 1, n, 0, 1, "vf", 1/30, true);
	resoLevel = OceanodeParameterLag.ar(\resolevel, 1, n, 0, 1, "vf", 1/30, true);
	loDriveLevel = OceanodeParameterLag.ar(\lodrivelevel, 2, n, 0, 4, "vf", 1/30, true);
	resonNum = OceanodeParameter.kr(\resonum, 100, n, 1, 100, "vi");
	gate = OceanodeParameter.kr(\gate, 0, n, 0, 1, "vi");

	// Output level with proper curve scaling
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Detect gate onset
	gate = Trig.kr(gate, 0.001);

	// Generate resonator frequencies when gate triggers
	freqs = { TExpRand.kr(minFreq, maxFreq, gate) } ! maxResonators;

	// Generate envelopes
	locutoffenv = EnvGen.ar(Env.perc(0.5 * att, time), gate) * locut + 10;
	lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1 * att, time/2.5), gate) * hicut);
	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
	hidriver = hidriver * EnvGen.ar(Env.perc(1 * att, time/1.6, 0.25), gate);

	thwack = EnvGen.ar(Env.perc(0.001 * att, 0.001, 1), gate) * thwackLevel;

	// Create resonators
	res = Mix.fill(maxResonators, { |i|
		var isActive = i < resonNum;
		Ringz.ar(
			lodriver + hidriver + thwack,
			freqs[i],
			time
		) * isActive
	}) / maxResonators * resoLevel;

	// Mix final signal
	res = (res + (lodriver * loDriveLevel) + thwack) * amp;

	// Output
	Out.ar(OceanodeOutput.kr(\out), res);
}, description: "Physical model of a cymbal with controllable resonators", category: "Source/Physical Modeling");
)