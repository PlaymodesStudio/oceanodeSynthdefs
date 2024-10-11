(
SynthDef(\beatrepeat13, {
    arg in=0, out=0, bufferSize=4;
    var onoff=\go.kr(0), rate=\rate.kr(1);
    var reset=\reset.kr(0);  // Reset parameter
    var amp=1;
    var recms=\repms.kr(1000);
    var gate=1-\gate.kr(1);
    var ratestep=\pitchstep.kr(0);
    var reverse=((1-\reverse.kr(0))*2)-1;
    var envtime;
    var input, buffer, playhead, output, loopOutput;
    var recTrig, recTime, playTrig, bufferEnd, isLooping;
    var fixedTimeGate, fixedTimeEnd;
    var numChannels = 13;
    var mixPhase, resetTrig;
    var declickEnv;
    var loopPhase;
    var mix, play, wetGate;
    var bufferPlayRate, actualPlayPos, loopDur, loopReset, phasor, combinedResetTrig;
    var declick = \declick.kr(0.005);  // Declick time in seconds, default to 5ms
    var loopCount, currentRate;
    var onoffTrig;
	var mixedOutput;
	var transitionEnv;
	var ramp;

    // Create a local buffer
    buffer = LocalBuf(SampleRate.ir * bufferSize, numChannels).clear;

    // Input signal
    input = In.ar(in, numChannels);

    // Detect start of recording and create reset trigger
    onoffTrig = Trig1.kr(onoff);
    resetTrig = Trig1.kr(reset);
    recTrig = onoffTrig;

    // Combined reset trigger for both 'go' and 'reset'
    combinedResetTrig = Trig1.ar(K2A.ar(onoff) + K2A.ar(reset), ControlDur.ir);

    // Create a gate that closes after fixed time
    fixedTimeGate = EnvGen.kr(Env([0, 1, 0], [0, recms/1000], ['step', 'step']), recTrig);
    fixedTimeEnd = TDelay.kr(1 - fixedTimeGate, recms/1000);

    // Link mix to onoff, but delayed by recms
    mix = DelayN.kr(onoff, recms/1000, recms/1000);

    // Create a gate for the wet signal that opens after recms
    wetGate = DelayN.kr(onoff, recms/1000, recms/1000);

    // Link play to onoff with delay
    play = onoff;

    // Detect end of recording
    playTrig = Trig1.kr(fixedTimeEnd);

    // Determine buffer end and loop duration
    bufferEnd = recms / 1000;
    loopDur = bufferEnd;

    // Record to buffer
    RecordBuf.ar(input, buffer, loop: 0, trigger: recTrig);

    // Create a loop reset trigger using Phasor
    phasor = Phasor.ar(combinedResetTrig, 1 / (SampleRate.ir * loopDur), 0, 1);
    loopReset = (phasor - Delay1.ar(phasor) > 0).clip(0, 1);

    // Count loop cycles, resetting when either 'go' or 'reset' triggers
    loopCount = PulseCount.ar(loopReset, combinedResetTrig);

    // Calculate current rate based on ratestep (in semitones)
    currentRate = rate * (2 ** (ratestep * loopCount / 12));

    // Calculate buffer play rate
    bufferPlayRate = currentRate * BufRateScale.kr(buffer);

    // Playhead for buffer playback
    playhead = Phasor.ar(
        trig: loopReset,
        rate: bufferPlayRate * reverse,
        start: 0,
        end: bufferEnd * SampleRate.ir,
        resetPos: 0
    );

    // Calculate actual play position, clamping for rates < 1
    actualPlayPos = if(
        currentRate < 1,
        playhead.clip(0, bufferEnd * currentRate * SampleRate.ir),
        playhead % (bufferEnd * SampleRate.ir)
    );

    // Create the envelope as described
    envtime = (recms/1000) - (2 * declick);
    declickEnv = EnvGen.ar(
        Env(
            levels: [0, 1, 1, 0],
            times: [declick, envtime-(envtime*gate), declick],
            curve: [\lin, \step, \lin]
        ),
        gate: loopReset,
        levelScale: 1,
        levelBias: 0,
        timeScale: 1
    );

    // Play from buffer only if we're looping
    loopOutput = BufRd.ar(numChannels, buffer, actualPlayPos, loop: 1) * play * declickEnv * wetGate;

    // Mix input and loop output
    mixedOutput = (input * (1 - mix)) + (loopOutput * mix);

    // Create a fast ramping envelope for smooth transitions
    transitionEnv = Env.asr(declick, 1, declick, 'sine');
    ramp = EnvGen.ar(transitionEnv, K2A.ar(onoff));

    // Use SelectX for smooth transition between dry and wet signals
    output = SelectX.ar(ramp, [input, mixedOutput]);

    Out.ar(out, output * amp);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
