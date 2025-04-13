(
~synthCreator.value("DynamicCompressor", {|n|
	// Input signals and parameters
	var source, signalLevel, gainReduction, gainComputer, control, output;
	var threshold, ratio, knee, attack, release, makeup,y1;

	// Get input signal
	source = In.ar(OceanodeInput.kr(\in), n);

	// Parameters
	threshold = OceanodeParameter.kr(\threshold, -20, n, -60, 0, "vf");
	ratio = OceanodeParameter.kr(\ratio, 4, n, 1, 20, "vf");
	knee = OceanodeParameter.kr(\knee, 0, n, 0, 20, "vf");
	attack = OceanodeParameter.kr(\attack, 0.003, n, 0.0001, 1, "vf");
	release = OceanodeParameter.kr(\release, 0.1, n, 0.01, 2, "vf");
	makeup = OceanodeParameter.kr(\makeup, 0, n, 0, 20, "vf");

	// Convert attack and release times to filter coefficients
	attack = exp(-1/(attack * SampleRate.ir));
	release = exp(-1/(release * SampleRate.ir));

	// Rectify the signal
	signalLevel = 20 * log10(abs(source) + 0.00001); // Convert to dB with safety offset

	// Smooth Decoupled Peak Detector in the log domain (as per section 2.3.4 and 3.2)
	gainComputer = { |level|
		var overdB, compress;

		// Soft knee implementation (section 2.2)
		overdB = level - threshold;

		// Apply compression curve with knee (Equation 4)
		compress =
			Select.kr(
				(overdB < (knee.neg * 0.5)) * 1.0, // Condition 1: below knee start
				[
					Select.kr(
						(overdB > (knee * 0.5)) * 1.0, // Condition 2: above knee end
						[
							// Inside knee range - apply soft knee formula
							overdB + ((1/ratio - 1) * ((overdB + (knee * 0.5)).squared) / (2 * knee)),
							// Above knee - apply full compression
							threshold + (overdB / ratio)
						]
					),
					// Below knee - no compression
					level
				]
			);

		// Determine gain reduction amount
		level - compress
	};

	// Calculate gain reduction using log domain detector (Section 3.2)
	// Using the decoupled peak detector with smoothing from Section 2.3.4
	gainReduction = gainComputer.(signalLevel);

	// Apply smooth peak detector in the log domain (Equation 17)
	// Using first stage for instantaneous tracking with release smoothing
	 y1 = max(gainReduction, release * LocalIn.ar(n) + (1 - release) * gainReduction);
	// Second stage for attack smoothing
	control = (attack * LocalOut.ar(y1)) + ((1 - attack) * y1);

	// Convert gain reduction from dB to linear gain factor and apply makeup gain
	control = 10.pow((control + makeup) / 20);

	// Apply gain control to signal and output
	output = source * control;

	// Output the compressed signal
	Out.ar(OceanodeOutput.kr(\out), output);
},
description: "Dynamic range compressor with adjustable threshold ratio knee attack and release times",
category: "Effect/Dynamics");
)