(
~synthCreator.value("ChebyShaper", {|n|
	var input, output, chebyPolys, harmonicAmps;
	var drive, mix, levels;
	var numHarmonics = 64;

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Parameters
	drive = OceanodeParameterLag.ar(\drive, 1, n, 0.1, 10, "vf", 1/30, true);
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Harmonic amplitudes array (32 harmonics)
	harmonicAmps = OceanodeParameterLag.ar(\harmonics_64, 1, numHarmonics, 0, 2, "vf", 1/30, true);

	// Process each channel individually
	output = Array.fill(n, { |chanNum|
		var chanInput = input[chanNum];
		var driveLimited, chebyResult;

		// Apply drive and limit to prevent overflow
		driveLimited = (chanInput * drive[chanNum]).clip(-0.99, 0.99);

		// Calculate Chebyshev polynomials using recurrence relation
		// T_0(x) = 1, T_1(x) = x, T_{n+1}(x) = 2x*T_n(x) - T_{n-1}(x)
		chebyPolys = Array.newClear(numHarmonics + 1);
		chebyPolys[0] = 1;                    // T_0(x) = 1 (not used in output)
		chebyPolys[1] = driveLimited;         // T_1(x) = x

		// Generate T_2 through T_32 using recurrence relation
		(2..numHarmonics).do { |harmonic|
			chebyPolys[harmonic] = (2 * driveLimited * chebyPolys[harmonic-1]) - chebyPolys[harmonic-2];
		};

		// Combine harmonics: sum of h_n * T_n(x) for n = 1 to 32
		chebyResult = Array.fill(numHarmonics, { |harmIndex|
			harmonicAmps[harmIndex] * chebyPolys[harmIndex + 1]  // +1 because we want T_1 to T_32
		}).sum;

		chebyResult = chebyResult.tanh; // Soft saturation

		// Return processed channel
		chebyResult;
	});

	// Apply dry/wet mix using XFade2
	output = Array.fill(n, { |i|
		XFade2.ar(input[i], output[i], mix[i].linlin(0, 1, -1, 1));
	});

	// Apply final level control
	output = output * levels;

	// Output the processed signal
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Chebyshev polynomial waveshaper with 32 controllable harmonics", category: "Effect/Distortion");
)