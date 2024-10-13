d = thisProcess.nowExecutingPath.dirname;


(
SynthDef(\beatrepeat13, {
    arg in=0, out=0, bufferSize=20;
    var onoff=\go.kr(0);
    var recms=\repms.kr(1000);
    var offset=\offset.kr(0)/1000.0;
    var gate=\gate.kr(1);
    var declick = \declick.kr(0.005);
    var rate = \rate.kr(1);
    var reverse = \reverse.kr(0);
    var pitchstep = \pitchstep.kr(0);
    var grainamp = \grainamp.kr(1);
    var input, buffer, output, loopOutput;
    var numChannels = 13;
    var writePos, readPos, bufFrames, offsetSamples, loopSamples;
    var recording;
    var declickEnv, gateEnv;
    var mix, play, wetGate, mixedOutput;
    var loopDur, loopReset, loopPhase, gatePhase;
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
    // Quantized parameters
    var qRecms, qOffset, qGate, qRate, qReverse, qPitchstep, qgrainamp;

    bufFrames = (bufferSize * SampleRate.ir).max(1);
    buffer = LocalBuf(bufFrames, numChannels).clear;
    input = In.ar(in, numChannels);

    // Asymmetric delay for onoff (playback)
    onoffDelay = (recms/1000) * onoff;
    delayedOnoff = DelayN.kr(onoff, recms/1000, onoffDelay);

    // Modified recording logic for rapid transitions
    recordTrig = 1 - onoff;
    recordReset = Trig.kr(onoff);
    recording = (1 - delayedOnoff) + Trig1.kr(recordTrig, recms/1000);

    writePos = Phasor.ar(recordReset, BufRateScale.kr(buffer) * recording, 0, BufFrames.kr(buffer));
    BufWr.ar(input, buffer, writePos);

    onoffTrig = Trig.kr(onoff);
    combinedResetTrig = Trig1.ar(K2A.ar(delayedOnoff) + K2A.ar(reset), ControlDur.ir);

    loopDur = recms / 1000;
    loopPhase = Phasor.ar(combinedResetTrig, 1 / (SampleRate.ir * loopDur), 0, 1, 0);
    gatePhase = Phasor.ar(onoffTrig, 1 / (SampleRate.ir * loopDur), 0, 1, 0);

    loopReset = Trig1.ar((loopPhase - Delay1.ar(loopPhase)) > 0, ControlDur.ir);

    // Quantize parameters
    qRecms = Latch.kr(recms, loopReset);
    qOffset = Latch.kr(offset, loopReset);
    qGate = Latch.kr(gate, loopReset);
    qRate = Latch.kr(rate, loopReset);
    qReverse = Latch.kr(reverse, loopReset);
    qPitchstep = Latch.kr(pitchstep, loopReset);
    qgrainamp = Latch.kr(grainamp, loopReset);

    loopSamples = (qRecms / 1000 * SampleRate.ir).round(1).max(1);
    offsetSamples = (qOffset * SampleRate.ir).round(1);

    loopCount = PulseCount.ar(loopReset, combinedResetTrig);
    currentRate = qRate * (2 ** (qPitchstep * loopCount / 12));
    effectiveRate = currentRate * (1 - (qReverse * 2));

    readPos = Phasor.ar(
        trig: loopReset,
        rate: BufRateScale.kr(buffer) * effectiveRate,
        start: qReverse * loopSamples,
        end: (1 - qReverse) * loopSamples,
        resetPos: qReverse * loopSamples
    );
    readPos = writePos - offsetSamples - loopSamples + readPos;
    readPos = readPos.wrap(0, BufFrames.kr(buffer) - 1);

    mix = delayedOnoff;
    wetGate = delayedOnoff;
    play = delayedOnoff;

    envtime = (qRecms/1000 - (2 * declick)).max(0);
    declickEnv = EnvGen.ar(
        Env(
            levels: [0, 1, 1, 0],
            times: [declick, envtime, declick],
            curve: [\sin, \step, \sin]
        ),
        gate: loopReset
    );

    gateEnv = (gatePhase < qGate).lag(declick.min(loopDur / 4));

    loopOutput = BufRd.ar(numChannels, buffer, readPos, loop: 1);
    loopOutput = loopOutput * play * declickEnv * qgrainamp;

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


