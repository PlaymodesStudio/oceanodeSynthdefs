(
SynthDef(\looper, {
    arg in=0, out=0, bufferSize=16;
    var rec=\rec.kr(0), rate=\rate.kr(1), amp=\amp.kr(1), mix=\mix.kr(1);
    var start=\start.kr(0), end=\end.kr(1);
    var autoplay=\autoplay.kr(1), play=\play.kr(0);
    var fixedtime=\fixedtime.kr(0), recms=\recms.kr(1000);
    var input, buffer, playhead, output, loopOutput;
    var recTrig, recTime, playTrig, bufferEnd, isLooping, minLoopDuration;
    var loopStart, loopEnd, playResetTrig, fixedTimeGate, fixedTimeEnd;

    // Create a local buffer
    buffer = LocalBuf(SampleRate.ir * bufferSize, 1).clear;

    // Input signal
    input = In.ar(in);

    // Minimum loop duration
    minLoopDuration = 0.01;

    // Detect start of recording
    recTrig = Trig1.kr(rec);

    // Create a gate that closes after fixed time when fixedtime=1
    fixedTimeGate = EnvGen.kr(Env([0, 1, 0], [0, recms/1000], ['step', 'step']), recTrig);
    fixedTimeEnd = TDelay.kr(1 - fixedTimeGate, recms/1000);

    // Detect end of recording (either manual stop or fixed time end)
    playTrig = Trig1.kr((1 - rec) + (fixedtime * fixedTimeEnd));

    // Detect changes in play from 0 to 1
    playResetTrig = Trig1.kr(play);

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

    // Record to buffer
    RecordBuf.ar(input, buffer, loop: 0, trigger: recTrig);

    // Determine if we're looping
    isLooping = (bufferEnd > minLoopDuration) * (autoplay + play - (autoplay * play));

    // Playhead for buffer playback
    playhead = Phasor.ar(
        trig: playTrig + playResetTrig,  // Reset on playTrig or playResetTrig
        rate: BufRateScale.kr(buffer) * rate,
        start: loopStart,
        end: loopEnd,
        resetPos: loopStart
    );

    // Play from buffer only if we're looping
    loopOutput = BufRd.ar(1, buffer, playhead, loop: 1) * isLooping;

    // Mix input and loop output
    output = XFade2.ar(input, loopOutput, isLooping * (mix * 2 - 1), amp);

    Out.ar(out, output ! 2);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


// Start the looper with autoplay on and fixed recording time
l = Synth(\looper, [\in, 0, \bufferSize, 16, \autoplay, 1, \fixedtime, 1, \recms, 100]);

// Start recording (will record for 2 seconds and automatically start playing)
l.set(\rec, 1);

// The loop should automatically start playing after 2 seconds without needing to set rec to 0

// You can still manually stop recording before the fixed time if needed
// l.set(\rec, 0);

// Other controls work as before
l.set(\mix, 0.5);
l.set(\rate, 1.5);
l.set(\start, 0.25, \end, 0.75);

// Switch to variable time recording
l.set(\fixedtime, 1);
l.set(\autoplay, 1);

// Start recording (now it will record until you manually stop)
l.set(\rec, 1);

// Stop recording and start playing (because autoplay is still 1)
l.set(\rec, 0);
l.set(\play, 1);
l.set(\play, 0);

// Clean up
l.free;

(
SynthDef(\looper13, {
    arg in=0, out=0, bufferSize=16;
    var rec=\rec.kr(0), rate=\rate.kr(1), amp=\amp.kr(1!13), mix=\mix.kr(1);
    var start=\start.kr(0), end=\end.kr(1);
    var autoplay=\autoplay.kr(1), play=\play.kr(0);
    var fixedtime=\fixedtime.kr(0), recms=\recms.kr(1000);
    var input, buffer, playhead, output, loopOutput;
    var recTrig, recTime, playTrig, bufferEnd, isLooping, minLoopDuration;
    var loopStart, loopEnd, playResetTrig, fixedTimeGate, fixedTimeEnd;
    var numChannels = 13;
    var mixPhase, resetTrig;
    var declickEnv, declickDur = 0.005; // 5ms declick duration
    var loopDur, loopPhase;
	var envShape = \declick.kr(4); // Adjustable: higher values make the envelope more square-like

    // Create a local buffer for 13 channels
    buffer = LocalBuf(SampleRate.ir * bufferSize, numChannels).clear;

    // Input signal (13 channels)
    input = In.ar(in, numChannels);

    // Minimum loop duration
    minLoopDuration = 0.01;

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

    // Record to buffer (13 channels)
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
	declickEnv = ((SinOsc.ar(0,loopPhase * 2pi)+1)/2).pow(envShape);

    // Play from buffer only if we're looping (13 channels)
    loopOutput = BufRd.ar(numChannels, buffer, playhead, loop: 1) * isLooping * declickEnv;

    // Calculate mix phase for crossfading
    mixPhase = isLooping * (mix * 2 - 1);

    // Mix input and loop output (13 channels)
    output = (input * (1 - mixPhase).clip(0, 1)) + (loopOutput * mixPhase.clip(0, 1));

    Out.ar(out, output * amp);
}).writeDefFile(d);
)

