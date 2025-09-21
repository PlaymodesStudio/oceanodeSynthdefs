(
~synthCreator.value("LFO", {|n|
	var freq, phaseOffset, pulseWidth, invert, shape, minVal, maxVal, reset;
	var phasor, linPhase, val, invVal, finalSig;
	var pow, quant, randomAdd, externalph, extphinput;

	// Basic LFO controls
	freq = OceanodeParameterLag.ar(\freq, 1, n, 0.01, 20, "vf", 1/30, true);
	phaseOffset = OceanodeParameterLag.ar(\phoff, 0, n, 0, 1, "vf", 1/30, true);
	pulseWidth = OceanodeParameterLag.ar(\pw, 0.5, n, 0, 1, "vf", 1/30, true);
	minVal = OceanodeParameterLag.ar(\min, 0, n, -1, 1, "vf", 1/30, true);
	maxVal = OceanodeParameterLag.ar(\max, 1, n, -1, 1, "vf", 1/30, true);
	invert = OceanodeParameterLag.ar(\invert, 0, n, 0, 1, "vf", 1/30, true);
	pow = OceanodeParameterLag.ar(\pow, 0, n, -1, 1, "vf", 1/30, true);
	quant = OceanodeParameter.ar(\quant, 0, n, 0, 64, "vi");
	randomAdd = OceanodeParameterLag.ar(\rndmadd, 0, n, 0, 1, "vf", 1/30, true);
	shape = OceanodeParameterFloatDropdown.kr(\shape, 0, n, "Saw:Sine:Triangle:Pulse:Noise");
	reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");

	// New external phase control
	externalph = OceanodeParameter.ar(\externalph, 0, n, 0, 1, "vi");
	extphinput = OceanodeParameterLag.ar(\extphinput, 0, n, 0, 1, "vf", 1/30, true);

	// Create phasor that runs from 0 to 1 with reset control or use external input
	phasor = Select.ar(externalph, [
		// Internal phasor
		Phasor.ar(Trig.ar(reset, 0.001), freq * SampleDur.ir, 0, 1),
		// External phasor input
		extphinput
	]);

	// Apply phase offset
	linPhase = (phasor + phaseOffset).wrap(0, 1);

	// Generate waveforms from the phase - all in 0-1 range
	val = SelectX.ar(shape, [
		// Saw (0 to 1 ramp)
		linPhase,
		// Sine
		(sin(linPhase * 2pi - pi) * 0.5) + 0.5,
		// Triangle
		(linPhase < 0.5) * (linPhase * 2) + (linPhase >= 0.5) * (2 - (linPhase * 2)),
		// Pulse
		(linPhase < pulseWidth) * 1.0,
		// Noise (different approach, not phase-based)
		LFDNoise3.ar(freq).range(0, 1)
	]);

	// Apply random noise (corrected to match original)
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

	// Apply quantization (corrected to match original)
	val = Select.ar(quant > 1, [
		val,
		(val * (quant - 1)).round / (quant - 1)
	]);

	// Create inverted version
	invVal = 1 - val;

	// Crossfade between normal and inverted with linear interpolation
	val = val * (1 - invert) + (invVal * invert);

	// Scale from 0-1 range to min-max range
	finalSig = val * (maxVal - minVal) + minVal;

	// Output signal
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "Low frequency oscillator with multiple waveforms and effects", category: "Modulation/LFO");
)