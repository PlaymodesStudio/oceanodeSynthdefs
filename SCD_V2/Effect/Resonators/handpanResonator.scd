(
~synthCreator.value("HandpanResonator", {|n|
	var freq, amp, strikePos, strikeCurve, coupling, damping, stiffness, brightness, decayTime;
	var modes, highModes, coupledModes, sig;
	var nModes = 6;
	var nHighModes = 4;
	var modeRatios = [1, 2.0, 2.83, 3.91, 4.95, 6.12];
	var highRatios = [8.23, 9.87, 11.54, 13.21];
	var input, send, mix, chanInput, wet;

	// Parameters with proper ranges
	freq = OceanodeParameter.kr(\pitch, 60, n, 0, 130, "vf").midicps;
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	strikePos = OceanodeParameter.kr(\strikepos, 0.3, n, 0, 1, "vf");
	strikeCurve = OceanodeParameter.kr(\strikecurve, 0.7, n, 0, 1, "vf");
	coupling = OceanodeParameter.kr(\coupling, 0.3, n, 0, 1, "vf");
	damping = OceanodeParameter.kr(\damping, 0.2, n, 0, 1, "vf");
	stiffness = OceanodeParameter.kr(\stiffness, 0.7, n, 0, 1, "vf");
	brightness = OceanodeParameter.kr(\brightness, 0.7, n, 0, 5, "vf");
	decayTime = OceanodeParameter.kr(\decaytime, 3.4, n, 0.1, 10, "vf");
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate signals for each channel
	sig = n.collect({ |chan|
		chanInput = input[chan] * send[chan];
		
		// Main modes using DynKlank
		modes = DynKlank.ar(
			// For each modeRatio (1, 2.0, etc), create specs
			`[
				[
					freq[chan] * modeRatios[0] * (1 + (stiffness[chan] * 0 * 0.005)),
					freq[chan] * modeRatios[0] * (1 + (stiffness[chan] * 0 * 0.005 * 1.1)),
					freq[chan] * modeRatios[1] * (1 + (stiffness[chan] * 1 * 0.005)),
					freq[chan] * modeRatios[1] * (1 + (stiffness[chan] * 1 * 0.005 * 1.1)),
					freq[chan] * modeRatios[2] * (1 + (stiffness[chan] * 2 * 0.005)),
					freq[chan] * modeRatios[2] * (1 + (stiffness[chan] * 2 * 0.005 * 1.1)),
					freq[chan] * modeRatios[3] * (1 + (stiffness[chan] * 3 * 0.005)),
					freq[chan] * modeRatios[3] * (1 + (stiffness[chan] * 3 * 0.005 * 1.1)),
					freq[chan] * modeRatios[4] * (1 + (stiffness[chan] * 4 * 0.005)),
					freq[chan] * modeRatios[4] * (1 + (stiffness[chan] * 4 * 0.005 * 1.1)),
					freq[chan] * modeRatios[5] * (1 + (stiffness[chan] * 5 * 0.005)),
					freq[chan] * modeRatios[5] * (1 + (stiffness[chan] * 5 * 0.005 * 1.1))
				],
				[
					sin(pi * strikePos[chan] * (0 + 1)) * 0.3,
					sin(pi * strikePos[chan] * (0 + 1)) * 0.15,
					sin(pi * strikePos[chan] * (1 + 1)) * 0.3,
					sin(pi * strikePos[chan] * (1 + 1)) * 0.15,
					sin(pi * strikePos[chan] * (2 + 1)) * 0.3,
					sin(pi * strikePos[chan] * (2 + 1)) * 0.15,
					sin(pi * strikePos[chan] * (3 + 1)) * 0.3,
					sin(pi * strikePos[chan] * (3 + 1)) * 0.15,
					sin(pi * strikePos[chan] * (4 + 1)) * 0.3,
					sin(pi * strikePos[chan] * (4 + 1)) * 0.15,
					sin(pi * strikePos[chan] * (5 + 1)) * 0.3,
					sin(pi * strikePos[chan] * (5 + 1)) * 0.15
				],
				[
					decayTime[chan] * (1 - damping[chan]) * exp(-0.3 * 0),
					decayTime[chan] * (1 - damping[chan]) * exp(-0.3 * 0) * 0.8,
					decayTime[chan] * (1 - damping[chan]) * exp(-0.3 * 1),
					decayTime[chan] * (1 - damping[chan]) * exp(-0.3 * 1) * 0.8,
					decayTime[chan] * (1 - damping[chan]) * exp(-0.3 * 2),
					decayTime[chan] * (1 - damping[chan]) * exp(-0.3 * 2) * 0.8,
					decayTime[chan] * (1 - damping[chan]) * exp(-0.3 * 3),
					decayTime[chan] * (1 - damping[chan]) * exp(-0.3 * 3) * 0.8,
					decayTime[chan] * (1 - damping[chan]) * exp(-0.3 * 4),
					decayTime[chan] * (1 - damping[chan]) * exp(-0.3 * 4) * 0.8,
					decayTime[chan] * (1 - damping[chan]) * exp(-0.3 * 5),
					decayTime[chan] * (1 - damping[chan]) * exp(-0.3 * 5) * 0.8
				]
			],
			chanInput
		) * 0.2;

		// Higher modes using frequency expansion
		highModes = DynKlank.ar(
			`[
				[
					freq[chan] * highRatios[0],
					freq[chan] * highRatios[0] * 1.001,
					freq[chan] * highRatios[1],
					freq[chan] * highRatios[1] * 1.001,
					freq[chan] * highRatios[2],
					freq[chan] * highRatios[2] * 1.001,
					freq[chan] * highRatios[3],
					freq[chan] * highRatios[3] * 1.001
				],
				[
					sin(pi * strikePos[chan] * (0 + 7)) * brightness[chan] * 0.1,
					sin(pi * strikePos[chan] * (0 + 7)) * brightness[chan] * 0.05,
					sin(pi * strikePos[chan] * (1 + 7)) * brightness[chan] * 0.1,
					sin(pi * strikePos[chan] * (1 + 7)) * brightness[chan] * 0.05,
					sin(pi * strikePos[chan] * (2 + 7)) * brightness[chan] * 0.1,
					sin(pi * strikePos[chan] * (2 + 7)) * brightness[chan] * 0.05,
					sin(pi * strikePos[chan] * (3 + 7)) * brightness[chan] * 0.1,
					sin(pi * strikePos[chan] * (3 + 7)) * brightness[chan] * 0.05
				],
				[
					decayTime[chan] * 0.5 * exp(-0.2 * 0) * 0.3,
					decayTime[chan] * 0.5 * exp(-0.2 * 0) * 0.2,
					decayTime[chan] * 0.5 * exp(-0.2 * 1) * 0.3,
					decayTime[chan] * 0.5 * exp(-0.2 * 1) * 0.2,
					decayTime[chan] * 0.5 * exp(-0.2 * 2) * 0.3,
					decayTime[chan] * 0.5 * exp(-0.2 * 2) * 0.2,
					decayTime[chan] * 0.5 * exp(-0.2 * 3) * 0.3,
					decayTime[chan] * 0.5 * exp(-0.2 * 3) * 0.2
				]
			],
			chanInput
		) * 0.15;

		// Coupled modes for resonance between tones
		coupledModes = DynKlank.ar(
			`[
				[freq[chan] * 1.5, freq[chan] * 2],
				[coupling[chan] * 0.1 * (1 - (0 * 0.3)), coupling[chan] * 0.1 * (1 - (1 * 0.3))],
				[decayTime[chan] * (1 - damping[chan]) * 0.3, decayTime[chan] * (1 - damping[chan]) * 0.3]
			],
			modes
		);

		// Mix all components
		wet = Mix([
			modes,
			highModes * brightness[chan],
			coupledModes * coupling[chan] * 0.3
		]);

		// Add subtle distortion
		wet = wet + (wet.abs * wet * 0.02);

		// Apply EQ
		wet = BPeakEQ.ar(wet, freq[chan] * 2.5, 0.7, 2);
		wet = BHiShelf.ar(wet, 5000, 1, brightness[chan] * 6);

		// Apply amplitude
		wet = wet * amp[chan];

		// Mix dry and wet signals
		XFade2.ar(input[chan], wet, mix[chan] * 2 - 1);
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Handpan resonator effect that applies handpan-like resonances to input audio", category: "Effect/Resonators");
)