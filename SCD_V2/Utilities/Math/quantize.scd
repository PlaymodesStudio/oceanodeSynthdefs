(
~synthCreator.value("Quantizer", {|n|
	var source, signal, qValues, qSize, output;

	// Input signal to be quantized
	source = In.ar(OceanodeInput.kr(\in), n);

	// Get quantization values list
	qValues = OceanodeParameter.ar(\qlist, 0, n, -100, 100, "vf");

	// Get size of quantization list (with default of 1)
	qSize = OceanodeParameter.kr(\qsize, 1, n, 1, 32, "i");

	// Mapping strength - 1.0 means full quantization, 0.0 means pass-through
	signal = OceanodeParameter.ar(\amount, 1, n, 0, 1, "vf");

	// Process one sample at a time, finding the closest value in qValues
	output = n.collect({|i|
		var inSample = source[i];
		var quantizedSample;
		var minDist = inf;
		var closestVal = inSample;

		// Iterate through qValues to find closest match
		qSize[i].do({|j|
			var qVal = qValues[i * 32 + j]; // Allow up to 32 quantization values per channel
			var dist = (inSample - qVal).abs;

			if(dist < minDist, {
				minDist = dist;
				closestVal = qVal;
			});
		});

		// Mix between original and quantized based on amount parameter
		inSample * (1 - signal[i]) + (closestVal * signal[i]);
	});

	// Apply level control with proper dB scaling
	output = output * OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Output the processed signal
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Quantizes input signal to nearest values in qlist", category: "Effect/Quantization");
)