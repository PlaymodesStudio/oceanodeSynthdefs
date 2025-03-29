(
~synthCreator.value("SitarResonator", {|n|
	var freq, amp, pos, bw, hc1, hc3, hfreq;
	var vc1, vc3, vfreq, dry, wet;
	var jawari, snd, gourd, input, send, mix;

	// Main parameters with lag for smooth transitions
	freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true);

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
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate signal for each channel
	snd = n.collect({ |chan|
		var chanInput = input[chan] * send[chan];
		
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
				inp: LPF.ar(chanInput, hfreq[chan])),
			DWGPlucked.ar(freq[chan] * jawari,
				pos: pos[chan],
				c1: vc1[chan],
				c3: vc3[chan],
				release: 1000,
				inp: LPF.ar(chanInput, vfreq[chan]))
		].sum;

		LocalOut.ar(snd);

		// Gourd resonance simulation
		gourd = BPF.ar(snd, [90, 132, 280], [1.3, 0.9, 1.4], [0.9, 0.6, 0.7]).sum;

		// Mixing dry and wet signals for the effect
		snd = (snd * dry[chan]) + (gourd * wet[chan]);

		// Apply amplitude with curve
		snd = snd * amp[chan].lincurve(0, 1, 0, 1, 4);
		
		// Mix dry and wet signals for the overall effect
		XFade2.ar(input[chan], snd, mix[chan] * 2 - 1);
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), snd);

}, description: "Sitar resonator effect that applies sitar-like resonances to input audio", category: "Effect/Resonators");
)