(
~synthCreator.value("Looper", {|n|
	var input, buffer, playhead, output, loopOutput;
	var recTrig, recTime, playTrig, bufferEnd, isLooping, minLoopDuration;
	var loopStart, loopEnd, playResetTrig, fixedTimeGate, fixedTimeEnd;
	var mixPhase, resetTrig, declickEnv, declickDur, envShape;
	var loopDur, loopPhase, bufferSize, numChannels;
	
	// Parameters
	var rec = OceanodeParameter.ar(\rec, 0, n, 0, 1, "vi");
	var rate = OceanodeParameter.ar(\rate, 1, n, 0.01, 8, "vf");
	var amp = OceanodeParameterLag.ar(\amp, 1, n, 0, 1, "vf", 1/50, true).lincurve(0, 1, 0, 1, 4);
	var mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	var start = OceanodeParameter.ar(\start, 0, n, 0, 1, "vf");
	var end = OceanodeParameter.ar(\end, 1, n, 0, 1, "vf");
	var autoplay = OceanodeParameter.ar(\autoplay, 1, n, 0, 1, "vi");
	var play = OceanodeParameter.ar(\play, 0, n, 0, 1, "vi");
	var fixedtime = OceanodeParameter.ar(\fixedtime, 0, n, 0, 1, "vi");
	var recms = OceanodeParameter.ar(\recms, 1000, n, 0, 10000, "vf");
	var declick = OceanodeParameter.ar(\declick, 0.1, n, 0, 1, "vf");
	var drywet = OceanodeParameter.ar(\drywet, 1, n, 0, 1, "vf");
	
	// Setup
	bufferSize = 16;
	numChannels = n;
	minLoopDuration = 0.01;
	
	// Create a local buffer
	buffer = LocalBuf(SampleRate.ir * bufferSize, numChannels).clear;
	
	// Input signal
	input = In.ar(OceanodeInput.kr(\in), numChannels);
	
	// Detect start of recording
	recTrig = Trig1.kr(rec);
	
	// Create a gate that closes after fixed time when fixedtime=1
	fixedTimeGate = EnvGen.kr(Env([0, 1, 0], [0, recms/1000], ['step', 'step']), recTrig);
	fixedTimeEnd = TDelay.kr(1 - fixedTimeGate, recms/1000);
	
	// Detect end of recording (either manual stop or fixed time end)
	playTrig = Trig1.kr((1 - rec) + (fixedtime * fixedTimeEnd));
	
	// Detect changes in play from 0 to 1
	playResetTrig = Trig1.kr(play);
	
	// Create reset trigger (don't reset if fixedtime=1 and autoplay=1)
	resetTrig = (playTrig + playResetTrig) * (1 - (fixedtime * autoplay));
	
	// Measure recording time
	recTime = Sweep.kr(recTrig);
	
	// Determine buffer end based on fixedtime
	bufferEnd = Select.kr(fixedtime, [
		Latch.kr(recTime, playTrig),
		recms / 1000  // Convert ms to seconds
	]).max(minLoopDuration);
	
	// Calculate actual loop start and end points
	loopStart = start * bufferEnd * SampleRate.ir;
	loopEnd = end * bufferEnd * SampleRate.ir;
	
	// Calculate loop duration
	loopDur = (loopEnd - loopStart) / SampleRate.ir;
	
	// Record to buffer
	RecordBuf.ar(input, buffer, loop: 0, trigger: recTrig);
	
	// Determine if we're looping
	isLooping = (bufferEnd > minLoopDuration) * (autoplay + play - (autoplay * play));
	
	// Playhead for buffer playback
	playhead = Phasor.ar(
		trig: resetTrig,
		rate: BufRateScale.kr(buffer) * rate,
		start: loopStart,
		end: loopEnd,
		resetPos: loopStart
	);
	
	// Calculate loop phase (0 to 1)
	loopPhase = (playhead - loopStart) / (loopEnd - loopStart);
	
	// Create declick envelope using loopPhase
	declickEnv = ((SinOsc.ar(0, loopPhase * 2pi) + 1) / 2).pow(declick * 4);
	
	// Play from buffer only if we're looping
	loopOutput = BufRd.ar(numChannels, buffer, playhead, loop: 1) * isLooping * declickEnv;
	
	// Calculate mix phase for crossfading
	mixPhase = isLooping * mix;
	
	// Mix input and loop output with dry/wet control
	output = XFade2.ar(input, loopOutput, mixPhase * 2 - 1);
	output = XFade2.ar(input, output, drywet * 2 - 1);
	
	Out.ar(OceanodeOutput.kr(\out), output * amp);
	
}, description: "Audio looper with variable speed and crossfade", category: "Effect/Time/Looping");
)