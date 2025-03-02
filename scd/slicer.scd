(
SynthDef(\sampleslicer2, {
    arg out=0;
    var buf, numFrames, sliceDur, signal;
    var gate, pitch, amp, sliceOffset;
    var env, sliceStart;
    var attack, decay;
    var playheadL, playheadR, levels;

    buf = \bufnum.kr(0!2);
    numFrames = BufFrames.kr(buf[0]);
    sliceDur = BufDur.kr(buf[0]) / \slices.kr(16).clip(1, 16);

    gate = \gate.kr(0!16);
    pitch = \pitch.kr(0!16).midiratio;
    amp = \amp.kr(1!16);
    sliceOffset = \offset.kr(0!16) * numFrames / \slices.kr(16);

    attack = \attack.kr(0.005);
    decay = \decay.kr(0.005);
	levels=\level.kr(1);

    sliceStart = Array.series(16, 0, numFrames / \slices.kr(16));

    #playheadL, playheadR = gate.collect({ |g, i|
        var sig = [
            PlayBuf.ar(1, buf[0], pitch[i], g, sliceStart[i] + sliceOffset[i], 0),
            PlayBuf.ar(1, buf[1], pitch[i], g, sliceStart[i] + sliceOffset[i], 0)
        ] * EnvGen.kr(
            Env([0,1,1,0], [attack, (sliceDur/pitch[i])-attack-decay, decay]),
            g
        ) * amp[i];
        sig;
    }).sum;

    Out.ar(out, [playheadL, playheadR]*levels);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
