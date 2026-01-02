(
~synthCreator.value("SigmoidOSC", {|n|
	var freq, peakX, inflection1, shape1, inflection2, shape2, levels;
	var sigmoidFlex, sigmoidEnv, phase, oscOut, finalSig;

	// Parameters
	freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 130, "vf", 1/30, true).midicps;
	peakX = OceanodeParameterLag.ar(\peakx, 0.3, n, 0.01, 0.99, "vf", 1/30, true);
	inflection1 = OceanodeParameterLag.ar(\inflection1, 0.5, n, 0.01, 0.99, "vf", 1/30, true);
	shape1 = OceanodeParameterLag.ar(\shape1, 0, n, -1, 1, "vf", 1/30, true);
	inflection2 = OceanodeParameterLag.ar(\inflection2, 0.5, n, 0.01, 0.99, "vf", 1/30, true);
	shape2 = OceanodeParameterLag.ar(\shape2, 0, n, -1, 1, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Sigmoid flex function - audio rate version
	sigmoidFlex = { |x, inflection = 0.5, shape = 0.0|
		var p, nu, a, b, result, shapeIsPositive, nuPositive, nuNegative;
		x = x.clip(0.0, 1.0);
		p = inflection.clip(0.01, 0.99);

		// Handle shape parameter with Select.ar for audio-rate conditionals
		shapeIsPositive = (shape >= 0);
		nuPositive = 1.0 + (shape * 9.0);
		nuNegative = 1.0 + (shape * 0.9);
		nu = Select.ar(shapeIsPositive, [nuNegative, nuPositive]);

		a = pow(x / p, nu);
		b = pow((1.0 - x) / (1.0 - p), nu);
		result = a / (a + b);
		result;
	};

	// Two-segment envelope function
	sigmoidEnv = { |x, decayX = 0.5, inflection1 = 0.5, shape1 = 0.0, inflection2 = 0.5, shape2 = 0.0, startY = 0.0, peakY = 1.0, endY = 0.0|
		var seg1, seg2, result;
		x = x.clip(0.0, 1.0);
		decayX = decayX.clip(0.01, 0.99);

		// First segment: startY to peakY (attack) from 0 to decayX
		seg1 = (startY + (peakY - startY) * sigmoidFlex.(x / decayX, inflection1, shape1)) * (x <= decayX);

		// Second segment: peakY to endY (decay/release) from decayX to 1
		seg2 = (endY + (peakY - endY) * (1.0 - sigmoidFlex.((x - decayX) / (1.0 - decayX), inflection2, shape2))) * (x > decayX);

		result = seg1 + seg2;
		result;
	};

	// Generate phase using Phasor
	phase = Phasor.ar(0, freq * SampleDur.ir, 0, 1);

	// Apply sigmoid envelope shaping to the phase
	oscOut = sigmoidEnv.(phase, peakX, inflection1, shape1, inflection2, shape2, 0.0, 1.0, 0.0);

	// Apply level control with proper curve
	finalSig = oscOut * levels;

	// Output
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "Flexible two segment sigmoid oscillator", category: "Source/Special");
)