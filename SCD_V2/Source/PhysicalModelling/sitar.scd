(
~synthCreator.value("Sitar", {|n|
	var freq, amp, trig, pos, bw, hc1, hc3, hfreq;
	var vc1, vc3, vfreq, dry, wet, att, rel;
	var pluck, jawari, snd, gourd;

	// Main parameters with lag for smooth transitions
	freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true);
	trig = OceanodeParameter.ar(\trigg, 0, n, 0, 1, "vi");

	// String characteristics
	pos = OceanodeParameterLag.ar(\pos, 0.1, n, 0, 1, "vf", 1/30, true);
	bw = OceanodeParameterLag.ar(\bandwidth, 1.03, n, 0, 10, "vf", 1/30, true);

	// Horizontal string parameters
	hc1 = OceanodeParameterLag.ar(\dec1, 1, n, 0, 10, "vf", 1/30, true);
	hc3 = OceanodeParameterLag.ar(\hiloss1, 100, n, 0.1, 3000, "vf", 1/30, true);
	hfreq = OceanodeParameterLag.ar(\lpf1, 102, n, 20, 130, "vf", 1/30, true).midicps;

	// Vertical string parameters
	vc1 = OceanodeParameterLag.ar(\dec2, 1, n, 0, 10, "vf", 1/30, true);
	vc3 = OceanodeParameterLag.ar(\hiloss2, 100, n, 0.1, 3000, "vf", 1/30, true);
	vfreq = OceanodeParameterLag.ar(\lpf2, 102, n, 20, 130, "vf", 1/30, true).midicps;

	// Mixing parameters
	dry = OceanodeParameterLag.ar(\dry, 0.5, n, 0, 1, "vf", 1/30, true);
	wet = OceanodeParameterLag.ar(\wet, 0.5, n, 0, 1, "vf", 1/30, true);

	// Envelope parameters
	att = OceanodeParameterLag.ar(\att, 0.001, n, 0.0001, 10, "vf", 1/30, true);
	rel = OceanodeParameterLag.ar(\rel, 0.03, n, 0.0001, 10, "vf", 1/30, true);

	// Generate signal for each channel
	snd = n.collect({ |chan|
		// Pluck impulse
		pluck = HPF.ar(WhiteNoise.ar, 400) *
			EnvGen.kr(Env.perc(att[chan], rel[chan], 0.5), trig[chan]);

		// Jawari (bridge) simulation through feedback
		jawari = LocalIn.ar(1);
		jawari = A2K.kr(jawari);
		jawari = jawari.linexp(-1, 1, bw[chan].reciprocal, bw[chan]);

		// String simulation (horizontal and vertical planes)
		snd = [
			DWGPlucked.ar(freq[chan] * jawari,
				pos: pos[chan],
				c1: hc1[chan],
				c3: hc3[chan],
				release: 1000,
				inp: LPF.ar(pluck, hfreq[chan])),
			DWGPlucked.ar(freq[chan] * jawari,
				pos: pos[chan],
				c1: vc1[chan],
				c3: vc3[chan],
				release: 1000,
				inp: LPF.ar(pluck, vfreq[chan]))
		].sum;

		LocalOut.ar(snd);

		// Gourd resonance simulation
		gourd = BPF.ar(snd, [90, 132, 280], [1.3, 0.9, 1.4], [0.9, 0.6, 0.7]).sum;

		// Mixing dry and wet signals
		snd = (snd * dry[chan]) + (gourd * wet[chan]);

		// Apply amplitude with curve
		snd * amp[chan]
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), snd);

}, description: "Digital waveguide sitar model with dual string planes and gourd resonance", category: "Source/PhysicalModelling");
)