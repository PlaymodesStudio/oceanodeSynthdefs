(
~synthCreator.value("ShimmerReverb", {|n|
	var input, wet, source, shimmerEffect, basicReverb, output;

	// Parameter controls with proper ranges
	var send = OceanodeParameter.ar(\send, 1, n, 0, 1, "vf");
	var predelay = OceanodeParameter.ar(\predelay, 0.1, n, 0, 1, "vf");
	var shimmer = OceanodeParameter.ar(\shimmer, 0.5, n, 0, 1, "vf");
	var tail = OceanodeParameter.ar(\tail, 3, n, 0.1, 16, "vf");
	var ratio1 = OceanodeParameter.ar(\ratio1, 2, n, 1, 4, "vf");
	var ratio2 = OceanodeParameter.ar(\ratio2, 4, n, 1, 8, "vf");
	var ratio3 = OceanodeParameter.ar(\ratio3, 8, n, 1, 12, "vf");
	var lpf = OceanodeParameter.ar(\lpf, 3000, n, 100, 20000, "vf");
	var mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	var level = OceanodeParameterLag.ar(\level, 1, n, 0, 1, "vf", 1/30, true);

		// Input audio - properly handle n channels
	input = In.ar(OceanodeInput.kr(\in), n);
	source = input.asArray;

	// Apply send control to input
	input = input * send;

	// Predelay - maintain n channels
	input = DelayN.ar(input, 1, predelay);

	// SHIMMER effect - creating higher harmonics with pitch shifting
	// Process each channel individually to maintain multichannel structure
	shimmerEffect = input;
	shimmerEffect = shimmerEffect + (PitchShift.ar(input, 0.13, ratio1, 0, 0.1, 1 * shimmer));
	shimmerEffect = shimmerEffect + (PitchShift.ar(input, 0.1, ratio2, 0, 0.1, 0.5 * shimmer));
	shimmerEffect = shimmerEffect + (PitchShift.ar(input, 0.1, ratio3, 0, 0.1, 0.25 * shimmer));

	// BASIC REVERB - maintain multichannel structure
	basicReverb = LPF.ar(shimmerEffect, lpf);

	// Use multichannel modulation that respects input channel count
	basicReverb = DelayC.ar(
		basicReverb,
		0.2,
		SinOsc.ar(0.3, {Rand(0, 2pi)}!n).linlin(-1, 1, 0, 0.001)
	);

	// Use multiple comb filters for each channel
	basicReverb = n.collect({ |i|
		var channel = basicReverb[i];
		CombL.ar(
			channel,
			0.1,
			Array.fill(4, { Rand(0.01, 0.099) }),
			tail * 2
		).sum / 4 // Normalize output level
	});

	// Add diffusion with allpass filters - 5 stages for higher quality
	5.do {
		basicReverb = basicReverb.collect({ |chan|
			AllpassN.ar(
				chan,
				0.1,
				Array.fill(4, { Rand(0.01, 0.099) }),
				tail * 1.5
			).sum / 4 // Normalize output level
		});
	};

	// Remove DC offset
	basicReverb = LeakDC.ar(basicReverb);

	// Mix dry and wet signal - maintain n channels
	output = XFade2.ar(source, basicReverb, mix * 2 - 1);

	// Output with level control
	Out.ar(OceanodeOutput.kr(\out), output * level);

}, description: "Harmonic shimmer reverb with pitch shifting", category: "Effect/Time/Reverb");
)