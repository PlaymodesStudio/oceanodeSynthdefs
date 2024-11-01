d = thisProcess.nowExecutingPath.dirname;


(
SynthDef(\beatrepeat13, {
    arg in=0, out=0;
	var bufferSize=8;
    var onoff=\go.kr(0);
    var recms=\repms.kr(1000);
    var adapt=\adaptlength.kr(0);
    var offset=\offset.kr(0)/1000.0;
    var gate=\gate.kr(1);
    var declick = \declick.kr(0.005);
    var rate = \rate.kr(1);
    var reverse = \reverse.kr(0);
    var pitchstep = \pitchstep.kr(0);
    var numsteps = \numpitchsteps.kr(12);
    var grainamp = \grainamp.kr(1);
    var input, buffer, output, loopOutput;
    var numChannels = 13;
    var writePos, readPos, bufFrames, offsetSamples, loopSamples;
    var recording;
    var declickEnv, gateEnv;
    var mix, play, wetGate, mixedOutput;
    var loopDur, adaptiveLoopDur, loopReset, loopPhase, gatePhase;
    var envtime;
    var effectiveRate;
    var loopCount, currentRate;
    var reset = \reset.kr(0);
    var combinedResetTrig;
    var delayedOnoff;
    var onoffTrig;
    var gatedDrySignal, gatedWetSignal, transitionOutput;
    var onoffDelay;
    var transitionEnv, fadeEnv;
    var recordTrig, recordReset;

    bufFrames = (bufferSize * SampleRate.ir).max(1);
    buffer = LocalBuf(bufFrames, numChannels).clear;
    input = In.ar(in, numChannels);

    loopDur = recms / 1000;
    currentRate = rate * (2 ** (pitchstep / 12));
    effectiveRate = currentRate * (1 - (reverse * 2));

    // Adaptive loop duration calculation
    adaptiveLoopDur = Select.kr(adapt, [loopDur, loopDur / currentRate.abs]);
    loopSamples = (adaptiveLoopDur * SampleRate.ir).round(1).max(1);

    // Asymmetric delay for onoff (playback)
    onoffDelay = adaptiveLoopDur * onoff;
    delayedOnoff = DelayN.kr(onoff, adaptiveLoopDur, onoffDelay);

    // Recording logic
    recordTrig = 1 - onoff;
    recordReset = Trig.kr(onoff);
    recording = (1 - delayedOnoff) + Trig1.kr(recordTrig, adaptiveLoopDur);

    writePos = Phasor.ar(recordReset, BufRateScale.kr(buffer) * recording, 0, BufFrames.kr(buffer));
    BufWr.ar(input, buffer, writePos);

    onoffTrig = Trig.kr(onoff);
    combinedResetTrig = Trig1.ar(K2A.ar(delayedOnoff) + K2A.ar(reset), ControlDur.ir);

    loopPhase = Phasor.ar(combinedResetTrig, 1 / (SampleRate.ir * adaptiveLoopDur), 0, 1, 0);
    gatePhase = Phasor.ar(onoffTrig, 1 / (SampleRate.ir * adaptiveLoopDur), 0, 1, 0);

    loopReset = Trig1.ar((loopPhase - Delay1.ar(loopPhase)) > 0, ControlDur.ir);

    loopCount = PulseCount.ar(loopReset, combinedResetTrig) % numsteps;

    // Quantize parameters
    currentRate = Latch.kr(currentRate, loopReset);
    effectiveRate = Latch.kr(effectiveRate, loopReset);
    adaptiveLoopDur = Latch.kr(adaptiveLoopDur, loopReset);
    loopSamples = Latch.kr(loopSamples, loopReset);
    gate = Latch.kr(gate, loopReset);
    grainamp = Latch.kr(grainamp, loopReset);

	offsetSamples = Latch.kr((offset * SampleRate.ir).round(1), loopReset);

    readPos = Phasor.ar(
        trig: loopReset,
        rate: BufRateScale.kr(buffer) * effectiveRate,
        start: reverse * loopSamples,
        end: (1 - reverse) * loopSamples,
        resetPos: reverse * loopSamples
    );
    readPos = writePos - offsetSamples - loopSamples + readPos;
    readPos = readPos.wrap(0, BufFrames.kr(buffer) - 1);

    mix = delayedOnoff;
    wetGate = delayedOnoff;
    play = delayedOnoff;

    envtime = (adaptiveLoopDur - (2 * declick)).max(0);
    declickEnv = EnvGen.ar(
        Env(
            levels: [0, 1, 1, 0],
            times: [declick, envtime, declick],
            curve: [\sin, \step, \sin]
        ),
        gate: loopReset
    );

    gateEnv = (gatePhase < gate).lag(declick.min(adaptiveLoopDur / 4));

    loopOutput = BufRd.ar(numChannels, buffer, readPos, loop: 1);
    loopOutput = loopOutput * play * declickEnv * grainamp;

    gatedDrySignal = input * gateEnv;
    gatedWetSignal = loopOutput * gateEnv;

    fadeEnv = EnvGen.ar(
        Env.asr(declick, 1, declick, 'sine'),
        gate: onoff
    );

    transitionEnv = EnvGen.ar(
        Env.asr(declick, 1, declick, 'sine'),
        gate: delayedOnoff
    );

    transitionOutput = XFade2.ar(
        gatedDrySignal,
        gatedWetSignal,
        transitionEnv * 2 - 1
    );

    output = SelectX.ar(fadeEnv, [input, transitionOutput]);

    Out.ar(out, output * \levels.kr(1, 1/50, fixedLag: true));
}).writeDefFile(d);
)

