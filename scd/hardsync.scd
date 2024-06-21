(
SynthDef(\hardsync13, {
	arg out=0;
	var freq, syncFreqRatio, masterOsc, slaveOsc, sync, amp;
	freq=\pitch.kr(36!13, 1/30, fixedLag: true).midicps;
	syncFreqRatio=\ratio.kr(1!13, 1/30, fixedLag: true);
	amp=\levels.kr(1!13, 1/30, fixedLag: true);
    masterOsc = Pulse.ar(freq, 0.5);
    slaveOsc = Saw.ar(freq * syncFreqRatio);
    sync = slaveOsc * (masterOsc < 0);
    Out.ar(out, sync*amp);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\hardsyncblsaw13, {
	arg out=0;
	var syncFreq = \syncpitch.kr(36!13, 1/30, fixedLag:true).midicps,
	    sawFreq = \sawpitch.kr(60!13, 1/30, fixedLag:true).midicps,
	    maxRatio = 20, minFreq = 10;
	var maxDelay = 1 / minFreq;
	var sig = Array.newClear(13);
	var levels = \levels.kr(1!13);
	var buffers;

	// Create an array of buffers, one for each channel
	buffers = Array.fill(13, { LocalBuf(1, Server.default.sampleRate * maxDelay) });

	// Iterate over each channel
	13.do { |i|
		var baseWaveform = Saw.ar(syncFreq[i]);
		var n = floor(maxRatio);
		var channelSig = 0; // Reset channelSig for each channel

		// Apply the hardsync algorithm to each channel independently
		n.do { |j|
			var delay = j / sawFreq[i];
			var amplitude = ((sawFreq[i] / syncFreq[i]) - j) min: 1 max: 0;
			channelSig = channelSig + (BufDelayL.ar(buffers[i], baseWaveform, delay) * amplitude);
		};

		// Assign the processed channel signal to the corresponding position in the array
		sig[i] = channelSig * levels[i];
	};

	// Output the multichannel signal
	Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef(\hardsyncblpulse13, {
	arg out=0;
	var syncFreq = \syncpitch.kr(36!13, 1/30, fixedLag:true).midicps,
	    sawFreq = \sawpitch.kr(60!13, 1/30, fixedLag:true).midicps,
	    maxRatio = 20, minFreq = 10;
	var maxDelay = 1 / minFreq;
	var sig = Array.newClear(13);
	var levels = \levels.kr(1!13);
	var pw=\pw.kr(0.5!13);
	var buffers;

	// Create an array of buffers, one for each channel
	buffers = Array.fill(13, { LocalBuf(1, Server.default.sampleRate * maxDelay) });

	// Iterate over each channel
	13.do { |i|
		var baseWaveform = Pulse.ar(syncFreq[i],pw[i]);
		var n = floor(maxRatio);
		var channelSig = 0; // Reset channelSig for each channel

		// Apply the hardsync algorithm to each channel independently
		n.do { |j|
			var delay = j / sawFreq[i];
			var amplitude = ((sawFreq[i] / syncFreq[i]) - j) min: 1 max: 0;
			channelSig = channelSig + (BufDelayL.ar(buffers[i], baseWaveform, delay) * amplitude);
		};

		// Assign the processed channel signal to the corresponding position in the array
		sig[i] = channelSig * levels[i];
	};

	// Output the multichannel signal
	Out.ar(out, sig);
}).writeDefFile(d);
)



