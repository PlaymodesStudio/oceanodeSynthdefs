(
~synthCreator.value("SigmoidEnv", {|n|
	var gate, useSustain, timeMs, peakX, inflection1, shape1, inflection2, shape2, levels;
	var sigmoidFlex, sigmoidEnv, envTime, envOut, finalSig;
	var attackTime, decayTime, env, envPhase;
	var oneShotPhase, basicADSR, prevADSR, isRising, isFalling;
	var attackNorm, attackCurved, releaseNorm, releaseCurved;
	var gateRise, oneShotEnv, sustainEnv;

	// Parameters
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	useSustain = OceanodeParameter.ar(\usesustain, 0, n, 0, 1, "vi");
	timeMs = OceanodeParameterLag.ar(\timems, 1000, n, 1, 10000, "vf", 1/30, true);
	peakX = OceanodeParameterLag.ar(\peakx, 0.3, n, 0.01, 0.99, "vf", 1/30, true);
	inflection1 = OceanodeParameterLag.ar(\inflection1, 0.5, n, 0.01, 0.99, "vf", 1/30, true);
	shape1 = OceanodeParameterLag.ar(\shape1, 0, n, -1, 1, "vf", 1/30, true);
	inflection2 = OceanodeParameterLag.ar(\inflection2, 0.5, n, 0.01, 0.99, "vf", 1/30, true);
	shape2 = OceanodeParameterLag.ar(\shape2, 0, n, -1, 1, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Sigmoid flex function - FIXED VERSION
	sigmoidFlex = { |x, inflection = 0.5, shape = 0.0|
		var p, nu, a, b, result, shapeIsPositive, nuPositive, nuNegative;
		x = x.clip(0.0, 1.0);
		p = inflection.clip(0.01, 0.99);

		// Correct shape parameter handling using Select.ar for audio-rate conditionals
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
		seg1 = (startY + (peakY - startY) * sigmoidFlex.(x / decayX, inflection1, shape1)) * (x <= decayX);
		seg2 = (endY + (peakY - endY) * (1.0 - sigmoidFlex.((x - decayX) / (1.0 - decayX), inflection2, shape2))) * (x > decayX);
		result = seg1 + seg2;
		result;
	};

	// Convert time to seconds - using peakX for proportional timing in BOTH modes
	envTime = timeMs / 1000;
	attackTime = envTime * peakX;      // Attack time proportional to peakX
	decayTime = envTime * (1 - peakX); // Release time proportional to (1 - peakX)

	// Detect gate transitions
	gateRise = Trig1.ar(gate, 0.01);  // Trigger on gate rising edge

	// One-shot mode: 0 to 1 ramp triggered EVERY TIME gate goes 0→1
	oneShotPhase = EnvGen.ar(
		envelope: Env([0, 0, 1], [0, envTime]),  // Start at 0, immediately go to 0, then to 1
		gate: gateRise,  // Triggers every time gate rises
		doneAction: 0
	);

	// Sustain mode: use the simplest possible approach
	// Create a basic ADSR envelope and then manually apply sigmoid shaping
	// based on where we are in the envelope progression

	// Basic ADSR envelope - this handles all the timing and state correctly
	// Using the same proportional timing as one-shot mode
	basicADSR = EnvGen.ar(
		envelope: Env.adsr(
			attackTime: attackTime,    // Uses peakX proportion
			decayTime: 0.01,           // Very short since we don't use decay
			sustainLevel: 1.0,
			releaseTime: decayTime     // Uses (1-peakX) proportion
		),
		gate: gate,
		doneAction: 0
	);

	// For sustain mode, we bypass the complex sigmoidEnv function entirely
	// Instead, we directly create attack and release curves and combine them

	// Simple approach: use the basic ADSR as a reference and apply shaping
	// Attack detection: envelope is rising (current > previous)
	prevADSR = Delay1.ar(basicADSR);
	isRising = basicADSR > prevADSR;
	isFalling = basicADSR < prevADSR;

	// For attack: normalize the rising portion and apply sigmoid
	// For release: normalize the falling portion and apply sigmoid
	// For sustain: just output the current level

	// Normalize attack: when rising, map current progress to 0-1 range
	attackNorm = basicADSR;  // During attack, basicADSR naturally goes 0→1
	attackCurved = sigmoidFlex.(attackNorm, inflection1, shape1);

	// Normalize release: when falling, we need to map 1→0 to 0→1 for sigmoid, then invert
	releaseNorm = 1.0 - basicADSR;  // Invert so falling becomes rising for sigmoid
	releaseCurved = 1.0 - sigmoidFlex.(releaseNorm, inflection2, shape2);  // Apply sigmoid then invert back

	// Choose which curve to use based on envelope state
	sustainEnv = Select.ar(isFalling, [
		// Not falling: either rising (attack) or flat (sustain)
		Select.ar(isRising, [
			basicADSR,  // Not rising: use basic envelope (sustain)
			attackCurved  // Rising: use sigmoid attack
		]),
		// Falling: use sigmoid release
		releaseCurved
	]);

	// Apply sigmoid shaping to one-shot mode
	oneShotEnv = sigmoidEnv.(oneShotPhase, peakX, inflection1, shape1, inflection2, shape2, 0.0, 1.0, 0.0);

	// Select between the two envelope types
	envOut = Select.ar(useSustain, [oneShotEnv, sustainEnv]);

	// Apply level control
	finalSig = envOut * levels;

	// Output
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "Flexible two segment sigmoid envelope generator", category: "Modulation/Envelope");
)