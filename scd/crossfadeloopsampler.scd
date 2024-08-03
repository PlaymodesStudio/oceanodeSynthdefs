d = thisProcess.nowExecutingPath.dirname;
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
SynthDef(\crosslooper13, {
	arg out=0;
	var numchans = 13, startFrames, adjustedLoopDur, trigs, gates, gateArray,signals,egs,mix;
	var buf=\bufnum.kr(0 ! numchans);
	var xfadetime = \xfadetime.kr(0.1 ! numchans);
	var loopDur = \loopdur.kr(0.5 ! numchans);
	var trigg = \trig.kr(0 ! numchans);
	var levels = \levels.kr(1 ! numchans, 1/30, fixedLag: true);
	var pitch = \pitch.kr(0 ! numchans); // Pitch in semitones
	var speed = pitch.midiratio; // Convert semitones to playback rate
	var keepregion = \keepregion.kr(1); // Boolean control for keeping region
	var start = \start.kr(0 ! numchans); // Start in seconds
	startFrames = start * BufFrames.kr(buf); // Convert seconds to frames

	// Adjust loop duration only if keepregion is true
	 adjustedLoopDur = keepregion * (loopDur / speed) + (1 - keepregion) * loopDur;
	 trigs = Impulse.kr(adjustedLoopDur.reciprocal) + Trig.kr(trigg, 0.0001);
	 gates = ToggleFF.kr(trigs);
	 gateArray = Array.fill(numchans, { |i| [gates[i], 1 - gates[i]] });

	 signals = Array.fill(numchans, { |i|
		PlayBuf.ar(1, buf, speed[i], trigger: gateArray[i], startPos: startFrames[i])
	});

	 egs = Array.fill(numchans, { |i|
		EnvGen.kr(Env.asr(xfadetime[i], 1, xfadetime[i], [-4, 4], curve: \welch), gateArray[i])
	});

	 mix = Array.fill(numchans, { |i|
		(signals[i] * egs[i] * levels[i]).sum
	});

	Out.ar(out, mix);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
