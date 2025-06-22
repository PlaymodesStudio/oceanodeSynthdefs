~synthCreator.value("SamplerJump", {|n|
    var t, gain, buf, spd, loop, start, numsamples;
    var rawOffset, delayedOffset, changeTrig, oldOffset, newOffset;
    var phA, phB, fadeEnv, sigA, sigB, signal;
    var fadetime;

    //–– Controls (all at AR where needed) ––
    t         = OceanodeParameter.ar(\trigger,  0,    n, 0, 1,    "vi");
    gain      = OceanodeParameterLag.ar(\levels, 0,    n, 0, 1,    "vf", 1/30, true)
                    .lincurve(0,1,0,1,4);
    buf       = OceanodeBuffer.kr(\bufnum);
    spd       = OceanodeParameter.ar(\speed,    1,    n, 0.25,4,   "vf");
    loop      = OceanodeParameter.kr(\loop,     0,    n, 0, 1,    "vi");
    start     = OceanodeParameter.ar(\startpos, 0,    n, 0, 1,    "vf")
                    * BufFrames.kr(buf);
    // **make offset AR** so it updates every sample
    rawOffset = OceanodeParameter.ar(\offset,   0,    n, -1, 1,    "vf")
                    * BufFrames.kr(buf);
    fadetime  = OceanodeParameter.ar(\fadetime, 0.005,n, 0.001,0.05,"vf");

    numsamples   = BufFrames.kr(buf);
    delayedOffset= Delay1.ar(rawOffset); // one-sample lookback at AR

    // trigger at AR when offset “jumps” by >0.1% of buffer
    changeTrig = Trig1.ar(
      (rawOffset - delayedOffset).abs > (numsamples * 0.001),
      fadetime * 2
    );

    // latch old vs. new pointers at the exact sample of change
    oldOffset = Latch.ar(delayedOffset, changeTrig);
    newOffset = Latch.ar(rawOffset,      changeTrig);

    // single-segment AR fade from 0→1; we'll invert for the old reader
    fadeEnv = EnvGen.ar(
      Env([0,1],[fadetime],[\lin]),
      changeTrig  // retriggers on each jump
    );

    // two readers, each at its own offset
    phA = Wrap.ar(
      Phasor.ar(t, BufRateScale.kr(buf)*spd, start, numsamples) + oldOffset,
      0, numsamples
    );
    phB = Wrap.ar(
      Phasor.ar(t, BufRateScale.kr(buf)*spd, start, numsamples) + newOffset,
      0, numsamples
    );
    sigA = BufRd.ar(1, buf, phA, loop, 0);
    sigB = BufRd.ar(1, buf, phB, loop, 0);

    // cross-fade: A goes 1→0, B goes 0→1
    signal = ((1 - fadeEnv) * sigA + fadeEnv * sigB) * gain;

    Out.ar(OceanodeOutput.kr(\out), signal);
},
description: "Click-free sampler: audio-rate cross-fade on offset jumps",
category: "Source/Sampler");
