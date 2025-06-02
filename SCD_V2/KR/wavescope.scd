

(
File.mkdir(d ++ "/" ++ "wavescope");

// Create SynthDefs for different sample sizes - NO DYNAMIC PARAMETERS
[32, 64, 128, 256, 512].do({|numSamples|
	(1..24).do({|numChannels|
		var synthName = ("wavescope" ++ numChannels ++ "_" ++ numSamples).asSymbol;

		SynthDef(synthName, {
			arg in, out, timewindow = 1;  // ONLY these 3 parameters
			var sig, bufferSize, writePhase;
			var sampleRate, samplesForTimeWindow;
			var outputSamples;
			var localBufs;

			sampleRate = SampleRate.ir;
			bufferSize = 10 * sampleRate;
			sig = In.ar(in, numChannels);

			// Create buffers
			localBufs = Array.fill(numChannels, { LocalBuf(bufferSize, 1) });
			writePhase = Phasor.ar(0, 1, 0, bufferSize);

			// Record
			numChannels.do({|i|
				RecordBuf.ar(sig[i], localBufs[i], writePhase, loop: 1);
			});

			samplesForTimeWindow = timewindow * sampleRate;

			// Generate output - numSamples is compile-time constant
			outputSamples = [];
			numChannels.do({|ch|
				numSamples.do({|sampleIdx|
					var readOffset = samplesForTimeWindow * (1 - (sampleIdx / (numSamples - 1)));
					var readPos = (writePhase - readOffset) % bufferSize;
					var sample = BufRd.kr(1, localBufs[ch], readPos, loop: 1, interpolation: 1);
					outputSamples = outputSamples.add(sample);
				});
			});

			Out.kr(out, outputSamples);

		}).writeDefFile(d ++ "/wavescope");

		// Progress indicator
		if((numChannels == 1) && ((numSamples == 32) || (numSamples == 128) || (numSamples == 512))) {
			("Creating: " ++ synthName).postln;
		};
	});
});

"✓ Clean wavescope SynthDefs created successfully".postln;
)