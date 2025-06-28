(
~synthCreator.value("MorphEnv", {|n|
	var trigger, timeMs, skew, shape, pw, levels;
	var getTriangle, getSine, getTrapezoid, getMultiLFO;
	var envTime, phase, morphOut, finalSig;

	// Parameters
	trigger = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
	timeMs = OceanodeParameterLag.ar(\timems, 1000, n, 1, 10000, "vf", 1/30, true);
	skew = OceanodeParameterLag.ar(\skew, 0.5, n, 0.00001, 0.99999, "vf", 1/30, true);
	shape = OceanodeParameterLag.ar(\shape, 0.5, n, 0, 1, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Morph function definitions
	getTriangle = { |phase, skew|
		var clippedSkew, scaledPhase;
		clippedSkew = skew.clip(0.00001, 0.99999);
		scaledPhase = phase.linlin(0, 1, clippedSkew.neg, 1 - clippedSkew);
		scaledPhase.bilin(0, clippedSkew.neg, 1 - clippedSkew, 1, 0, 0);
	};

	getSine = { |phase|
		1 - cos(phase * pi) / 2;
	};

	getTrapezoid = { |phase, shape|
		var steepness = 1 / (1 - shape);
		var trapezoid = (phase * steepness).clip(0, 1);
		var pulse = phase > 0;
		Select.ar((shape |==| 1).asInteger, [trapezoid, pulse]);
	};

	getMultiLFO = { |phase, skew, shape|
		var triangle, sine, blend, sineToTriangle, trapShape, triangleToTrap;
		triangle = getTriangle.(phase, skew);
		sine = getSine.(triangle);
		blend = shape * 2;
		sineToTriangle = sine * (1 - blend.clip(0, 1)) + (triangle * blend.clip(0, 1));
		trapShape = (blend - 1).clip(0, 1);
		triangleToTrap = getTrapezoid.(triangle, trapShape);
		Select.ar((blend < 1).asInteger, [triangleToTrap, sineToTriangle]);
	};

	// Convert time to seconds
	envTime = timeMs / 1000;

	// Generate phase for full cycle triggered by trigger input
	// Using EnvGen with a simple linear envelope from 0 to 1
	phase = EnvGen.ar(
		envelope: Env([0, 0, 1], [0, envTime]),  // Start at 0, immediately to 0, then to 1 over envTime
		gate: Trig1.ar(trigger, 0.01),  // Trigger on rising edge
		doneAction: 0
	);

	// Apply morph function to the phase
	morphOut = getMultiLFO.(phase, skew, shape);

	// Apply level control with proper curve
	finalSig = morphOut * levels.lincurve(0, 1, 0, 1, 4);

	// Output
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "Flexible morphing envelope generator", category: "Modulation/Envelope");
)