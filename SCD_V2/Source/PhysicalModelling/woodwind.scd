(
~synthCreator.value("Woodwind", {|n|
	var excitation, resonator, vibrato, output;
	var reedOsc, noise;
	var freq, pressure, breathAmt, nasality, lipPos, vibRate, vibDepth;
	var levels, reedStiff, resQ, nasalFreq, nasalRes;

	// Basic parameters
	freq = OceanodeParameterLag.ar(\pitch, 58, n, 24, 96, "vf", 1/30, true).midicps;

	// Performance parameters
	pressure = OceanodeParameter.ar(\pressure, 0.21, n, 0, 1, "vf");
	breathAmt = OceanodeParameter.ar(\breathamt, 0.081, n, 0, 0.5, "vf");
	nasality = OceanodeParameter.ar(\nasality, 4, n, 0, 10, "vf");
	lipPos = OceanodeParameter.ar(\lippos, 0.5, n, 0, 1, "vf");

	// Vibrato parameters
	vibRate = OceanodeParameter.ar(\vibrate, 5, n, 0.1, 10, "vf");
	vibDepth = OceanodeParameter.ar(\vibdepth, 0.001, n, 0, 0.1, "vf");

	// Global parameters
	reedStiff = OceanodeParameter.ar(\reedstiff, 0.97, n, 0.5, 1, "vf");
	resQ = OceanodeParameter.ar(\resq, 0.68, n, 0.1, 0.99, "vf");
	nasalFreq = OceanodeParameter.ar(\nasalfreq, 1600, n, 500, 5000, "vf");
	nasalRes = OceanodeParameter.ar(\nasalres, 0.987, n, 0.5, 0.999, "vf");

	// Level control
	levels = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Add vibrato
	vibrato = SinOsc.kr(vibRate, 0, vibDepth);
	freq = freq * (1 + vibrato);

	// Optimize noise generation
	noise = PinkNoise.ar * breathAmt * 0.02;

	// Reed oscillator with vibrato
	reedOsc = SinOsc.ar(freq) * pressure * 0.01;
	reedOsc = (reedOsc * reedStiff).tanh;

	// Combine breath and reed
	excitation = noise + reedOsc;

	// Resonator with lip position influence
	resonator = DynKlank.ar(
		`[
			[1, 2, 3, 4, 5],
			[1, 0.5, 0.25, 0.125, 0.0625],
			[1, 0.8, 0.6, 0.4, 0.2] * resQ
		],
		excitation,
		freq * (1 + (lipPos * 0.1))  // Lip position affects pitch slightly
	);

	// Enhanced formant filtering with nasalRes
	resonator = BPF.ar(
		resonator,
		nasalFreq * (1 + (lipPos * 0.2)),  // Lip position influences formant
		nasalRes * (0.1 + (nasality * 0.1))
	) * nasality + resonator;

	// Secondary formant for enhanced nasal character
	resonator = resonator + BPF.ar(
		resonator,
		nasalFreq * 2.5,
		nasalRes * 0.5
	) * (nasality * 0.3);

	// Final output
	output = resonator * levels;
	output = HPF.ar(output, 20);

	// Output
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Physical model of a woodwind instrument with breath and reed controls", category: "Sources/PhysicalModelling");
)