(
~synthCreator.value("Lissajous", {|n|
	var p, waves, pulsew, finalSig, fm, fmp, fma, phase;
	var sawOsc, triOsc, pulseOsc, phasor;
	var pow, bipow, shapedSig, mapPow, type, levels;

	// Parameters
	p = OceanodeParameter.ar(\pitch, 36, n, 24, 96, "vf");
	pulsew = OceanodeParameter.ar(\pw, 0.5, n, 0.01, 0.99, "vf");
	phase = OceanodeParameter.ar(\phase, 0, n, 0, 1, "vf");
	pow = OceanodeParameter.ar(\pow, 0, n, -1, 1, "vf");
	bipow = OceanodeParameter.ar(\bipow, 0, n, -1, 1, "vf");
	type = OceanodeParameter.ar(\type, 1, n, 0, 3, "vf");
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	
	// FM parameters
	fmp = OceanodeParameter.ar(\fmpitch, 48, n, 24, 96, "vf");
	fma = OceanodeParameter.ar(\fmamp, 0, n, 0, 10, "vf");

	// Mapping function for pow and bipow
	mapPow = { |x|
		var minExp = 1/32, maxExp = 32;
		Select.kr(x >= 0,
			[
				// For x < 0: map -1 to 0 to 1/32 to 1
				minExp.pow(1 - x.abs),
				// For x >= 0: map 0 to 1 to 1 to 32
				maxExp.pow(x)
			]
		);
	};
	pow = mapPow.(pow);
	bipow = mapPow.(bipow);

	// FM
	fm = SinOsc.ar(fmp.midicps, 0) * fma;

	// Phasor for custom oscillators
	phasor = phase + Phasor.ar(0, (p + fm).midicps / SampleRate.ir, 0, 1);

	// Custom oscillators with phase control
	sawOsc = (phasor * 2) - 1;
	triOsc = (phasor * 4 - 1).fold2(1);
	pulseOsc = (phasor < pulsew) * 2 - 1;

	// Array of waveforms
	waves = [
		sawOsc,
		triOsc,
		pulseOsc,
		SinOsc.ar(0, phasor * 2pi)
	];

	// Select waveform based on type parameter
	finalSig = SelectX.ar(type, waves);

	// Apply pow and bipow shaping
	shapedSig = finalSig.sign * (finalSig.abs ** bipow);
	shapedSig = shapedSig.sign * (shapedSig.abs ** pow);

	// Apply level control
	finalSig = shapedSig * levels;

	// Output
	Out.ar(OceanodeOutput.kr(\out), finalSig);
}, description: "Lissajous oscillator with multiple waveforms and waveshaping", category: "Source/Special");
)