d = thisProcess.nowExecutingPath.dirname; // Define d before using it



(
SynthDef(\dbaprouter13, {
    arg in=0, out=0;
    var input, output, ampArray;

    // Read 13 input channels
    input = In.ar(in, 13);

    // Array of 169 amplitudes (13x13 matrix)
    ampArray = \amplitudes.kr(Array.fill(169, 1.0));

    // Create array to store output channels
    output = Array.fill(13, 0);

    // For each input channel
    13.do({ |inputChan|
        var baseIndex = inputChan * 13;

        // Get the 13 amplitude values for this input channel
        var amps = Array.fill(13, { |i|
            ampArray[baseIndex + i]
        });

        // Add this input's contribution to each output channel
        output = output + (input[inputChan] * amps);
    });

    // Output all channels
    Out.ar(out, output);
}).writeDefFile(d);
)

(
SynthDef(\dbap13, {
    arg in=0, out=0;
    var speakerXPos, speakerYPos, sourceXPos, sourceYPos, rolloff;
    var inputs, distances, amplitudes, normFactors, outputSignals;

    // Input parameters
    speakerXPos = \speakerx.kr(Array.fill(13, { |i| i / 12.0 }), 1/30, fixedLag: true);  // Default spreads speakers evenly
    speakerYPos = \speakery.kr(Array.fill(13, { |i| i / 12.0 }), 1/30, fixedLag: true);
    sourceXPos = \x.kr(Array.fill(13, 0.5), 1/30, fixedLag: true);  // Default center
    sourceYPos = \y.kr(Array.fill(13, 0.5), 1/30, fixedLag: true);
    rolloff = \rolloff.kr(6.0);  // Spatial rolloff factor

    // Input audio signals - 13 channels
    inputs = In.ar(in, 13);

    // Calculate distances and amplitudes
    distances = Array.fill(13, { |speaker|
        Array.fill(13, { |source|
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
    normFactors = Array.fill(13, { |source|
        var sumSquared = 0;
        13.do({ |speaker|
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
    outputSignals = Array.fill(13, { |speaker|
        Mix.new(
            Array.fill(13, { |source|
                inputs[source] * amplitudes[speaker][source];
            })
        );
    });

    Out.ar(out, outputSignals);
}).writeDefFile(d);
)


