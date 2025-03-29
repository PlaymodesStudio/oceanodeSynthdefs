(
~synthCreator.value("DBAP", {|n, variables|
	var speakerXPos, speakerYPos, sourceXPos, sourceYPos, rolloff;
	var inputs, distances, amplitudes, normFactors, outputSignals;
	var numSpeakers = variables[0]; // First variable is number of speakers

	// Input audio signals
	inputs = In.ar(OceanodeInput.kr(\in), n);

	// Source positions and rolloff parameters
	sourceXPos = OceanodeParameterLag.ar(\position_x, 0.5, n, 0, 1, "vf", 1/30, true);
	sourceYPos = OceanodeParameterLag.ar(\position_y, 0.5, n, 0, 1, "vf", 1/30, true);

	// Speaker positions as vector parameters
	speakerXPos = OceanodeParameter.kr(\speaker_x,
		Array.fill(numSpeakers, {|i| 0.5 + (0.4 * cos(2 * pi * i / numSpeakers))}),
		1, 0, 1, "vf");
	speakerYPos = OceanodeParameter.kr(\speaker_y,
		Array.fill(numSpeakers, {|i| 0.5 + (0.4 * sin(2 * pi * i / numSpeakers))}),
		1, 0, 1, "vf");

	rolloff = OceanodeParameter.ar(\rolloff, 6, n, 0, 13, "vf");

	// Calculate distances and amplitudes
	distances = Array.fill(numSpeakers, { |speaker|
		Array.fill(n, { |source|
			var dx = speakerXPos[speaker] - sourceXPos[source];
			var dy = speakerYPos[speaker] - sourceYPos[source];
			sqrt(dx.squared + dy.squared);
		});
	});

	// Calculate amplitude for each speaker/source combination
	amplitudes = distances.collect({ |speakerDists|
		speakerDists.collect({ |dist|
			var amp = 1.0 / pow(max(dist, 0.00001), rolloff);  // Avoid division by zero
			amp
		});
	});

	// Normalize amplitudes
	normFactors = Array.fill(n, { |source|
		var sumSquared = 0;
		numSpeakers.do({ |speaker|
			sumSquared = sumSquared + amplitudes[speaker][source].squared;
		});
		1.0 / sqrt(max(sumSquared, 0.00001));  // Avoid division by zero
	});

	// Apply normalization
	amplitudes = amplitudes.collect({ |speakerAmps, speaker|
		speakerAmps.collect({ |amp, source|
			amp * normFactors[source];
		});
	});

	// Mix and output
	outputSignals = Array.fill(numSpeakers, { |speaker|
		Mix.new(
			Array.fill(n, { |source|
				inputs[source] * amplitudes[speaker][source];
			})
		);
	});

	// Output the processed signals (as many as speakers)
	Out.ar(OceanodeOutput.kr(\out), outputSignals);

}, description: "Distance-based amplitude panning", category: "Spatial/Panning", variables: ["NumSpeakers"], variableDimensions: [32]);
)