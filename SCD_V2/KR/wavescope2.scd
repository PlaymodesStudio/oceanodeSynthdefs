// Improved wavescope implementation - back to control bus approach
var d, wavescopeDir;

// Try to get the script directory, fallback to a default location
if(thisProcess.nowExecutingPath.notNil) {
	d = thisProcess.nowExecutingPath.dirname +/+ "/CompiledSynthdefs";
} {
	// Fallback to a default location if script path is unknown
	d = Platform.userAppSupportDir +/+ "/SuperCollider/CompiledSynthdefs";
};

wavescopeDir = d +/+ "/wavescope2";

// Create directories if they don't exist
File.mkdir(d);
File.mkdir(wavescopeDir);

(1..24).do({|numChannels|
	var synthName = ("wavescope_realtime" ++ numChannels).asSymbol;

	SynthDef(synthName, {
		arg in, out, frameRate = 60;
		var sig, buffers, writePos, outputSamples;
		var samplesPerFrame = 64; // Fixed frame size
		var bufSize = 256; // Larger buffer for sliding window

		// Input
		sig = In.ar(in, numChannels);

		// Position advancing at frame rate
		writePos = Phasor.ar(0, 1, 0, bufSize, 0);

		// One buffer per channel
		buffers = Array.fill(numChannels, { LocalBuf(bufSize) });

		// Write current signal to each buffer
		numChannels.do({|ch|
			BufWr.ar(sig[ch], buffers[ch], writePos);
		});

		// Read samples in overlapping sliding window
		outputSamples = Array.newClear(numChannels * samplesPerFrame);
		numChannels.do({|ch|
			samplesPerFrame.do({|i|
				var offset = (writePos - (samplesPerFrame - 1 - i)) % bufSize;
				var delayed = BufRd.ar(1, buffers[ch], offset, loop: 1);
				outputSamples[(ch * samplesPerFrame) + i] = A2K.kr(delayed);
			});
		});

		// Output to control bus
		Out.kr(out, outputSamples);

		// Also send phase updates for additional sync info
		SendReply.ar(Impulse.ar(frameRate), '/wavescope_phase', [writePos, numChannels]);

	}).writeDefFile(wavescopeDir);

	if([1, 2, 4, 8, 16, 24].includes(numChannels)) {
		("✓ Created: " ++ synthName ++ " (control bus + phase tracking)").postln;
	};
});

("✓ Improved wavescope SynthDefs created").postln;
"• Uses control bus for sample data streaming".postln;
"• Sends additional phase updates via SendReply".postln;
"• Maintains sliding window with proper overlap".postln;