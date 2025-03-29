(
~synthCreator.value("MorphLFO", {|n|
	var freq, phaseOffset, skew, width, shape, mix, minVal, maxVal;
	var phasor, phase, triangle, trapezoid, sine, val, finalSig;
	var reset, offset, steepness, pulse, pow, quant, randomAdd, invert, invVal;

	// Basic oscillator controls
	freq = OceanodeParameterLag.ar(\freq, 1, n, 0.01, 20, "vf", 1/30, true);
	phaseOffset = OceanodeParameterLag.ar(\phase, 0, n, 0, 1, "vf", 1/30, true);
	skew = OceanodeParameterLag.ar(\skew, 0, n, -1, 1, "vf", 1/30, true);
	width = OceanodeParameterLag.ar(\width, 0.5, n, 0, 1, "vf", 1/30, true);
	shape = OceanodeParameterLag.ar(\shape, 0, n, 0, 1, "vf", 1/30, true);
	mix = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);
	pow = OceanodeParameterLag.ar(\pow, 0, n, -1, 1, "vf", 1/30, true);
	quant = OceanodeParameter.ar(\quant, 0, n, 0, 64, "vi");
	randomAdd = OceanodeParameterLag.ar(\rndmadd, 0, n, -1, 1, "vf", 1/30, true);
	invert = OceanodeParameterLag.ar(\invert, 0, n, 0, 1, "vf", 1/30, true);
	minVal = OceanodeParameterLag.ar(\min, 0, n, -1, 1, "vf", 1/30, true);
	maxVal = OceanodeParameterLag.ar(\max, 1, n, -1, 1, "vf", 1/30, true);
	reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");

	// Create phasor that runs from 0 to 1
	phasor = Phasor.ar(Trig.ar(reset, 0.001), freq * SampleDur.ir, 0, 1);

	// Apply phase offset
	phase = (phasor + phaseOffset).wrap(0, 1);

	// Use simple version of skewed triangle to debug - simpler to trace issues
	triangle = (phase < 0.5) * (phase * 2) + (phase >= 0.5) * (2 - (phase * 2));

	// Apply skew after triangle creation - fixed to avoid if statement
	triangle = Select.ar(skew < 0, [
		// Positive skew
		1 - ((1 - triangle).pow(skew + 1)),
		// Negative skew
		triangle.pow(skew.neg + 1)
	]);

	// Ensure triangle is valid
	triangle = triangle.clip(0, 1);

	// Create trapezoid - simplified to debug
	trapezoid = ((triangle - (1-width)) / width).clip(0, 1);

	// Create sine
	sine = (sin(triangle * 2pi - pi) * 0.5) + 0.5;

	// Mix trapezoid and sine
	val = (trapezoid * (1 - mix)) + (sine * mix);

	// Apply random noise
	val = (val + (randomAdd * WhiteNoise.ar(0.5,0.5))).clip(0, 1);

	// Apply power transformation with proper scaling
	val = Select.ar(pow.abs > 0.01, [
		val,
		Select.ar(pow < 0, [
			// Positive pow: map 0-1 to 1-128
			val ** pow.linlin(0, 1, 1, 16),
			// Negative pow: map -1-0 to 0-1
			val ** pow.linlin(-1, 0, 0, 1)
		])
	]);

	// Apply quantization
	val = Select.ar(quant > 1, [
		val,
		(val * (quant - 1)).round / (quant - 1)
	]);

	// Create inverted version
	invVal = 1 - val;

	// Crossfade between normal and inverted with linear interpolation
	val = (val * (1 - invert)) + (invVal * invert);

	// Scale from 0-1 range to min-max range
	finalSig = (val * (maxVal - minVal)) + minVal;

	// Output signal
	Out.ar(OceanodeOutput.kr(\out), finalSig);
}, description: "Morphing oscillator with triangle trapezoid and sine shapes", category: "Modulation/LFO");
)