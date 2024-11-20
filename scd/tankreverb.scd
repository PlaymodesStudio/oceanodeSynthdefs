(
SynthDef.new(\tankreverb13, {
    arg in=0, out=0;
    var input, src, localin, tank, signal, wet;
    var sr = SampleRate.ir;
    var times, dtimes, delays;
    var earlydiffdtimes, earlydiffsize=4;
    var tanksize = 4;
    var numchannels = 13;

    input = In.ar(in, numchannels);
	//input=Impulse.ar(0.5)!numchannels;
    // Input processing
    src = HPF.ar(input, \inputhpf.kr(150!numchannels));
    src = OnePole.ar(src, \inputlpf.kr(0.5!numchannels));
    src = DelayN.ar(src, 0.1, \predelay.kr(0!numchannels));

    // Base delay times array
    times = [ 1447, 727, 613, 673, 1439, 2083, 2011, 1511, 1493, 1277, 2437, 2383, 2341, 997, 1061, 2039,
        1997, 1481, 1627, 1129, 743, 983, 1091, 907, 541, 2393, 1801, 2081, 1787, 1453, 977, 2311,
        691, 479, 2377, 1693, 1013, 1931, 1049, 2243, 839, 739, 1747, 601, 1823, 1123, 2467, 1297,
        1613, 1361, 2207, 593, 619, 1709, 449, 937 ];
    // Create unique delay time sequences for each channel
    dtimes = numchannels.collect({ |chan|
        var chandtimes, baseidx;
        baseidx = chan * (times.size.div(numchannels));
        chandtimes = times.rotate(baseidx);

        // Early diffusion times for this channel
        earlydiffdtimes = { chandtimes.removeAt(chandtimes.minIndex) } ! earlydiffsize;

        // Create delay line times for this channel
        delays = chandtimes.collect(_ * \scaledelays.kr(1!numchannels)[chan]);

        Routine{ (earlydiffdtimes ++ delays).do { |it| it.yield } }
    });
    // Early reflections - process each channel separately
    src = src.collect { |channel, i|
        var processed = channel;
        earlydiffsize.do {
            var dt = dtimes[i].next / sr;
            processed = AllpassN.ar(processed, dt, dt, \indiffusion.kr(0.05!numchannels)[i]);
        };
        processed
    };

    localin = LocalIn.ar(numchannels);
    // Main reverb tank - independent processing for each channel
    tank = numchannels.collect { |channel|
        var local = localin[channel];
        tanksize.collect { |i|
            var dt0, dt1, dt2;

            local = local + src[channel];

            dt0 = dtimes[channel].next / sr;
            dt1 = dtimes[channel].next / sr;
            dt2 = dtimes[channel].next / sr;

            local = AllpassC.ar(local, dt0, dt0, \decay.kr(0.5!numchannels)[channel]);
            local = AllpassC.ar(local, dt1, dt1, \decay1.kr(0.5!numchannels)[channel]);
            local = DelayC.ar(local, dt2, dt2 - (ControlDur.ir / tanksize) * LFNoise2.kr(0.3).range(0.9,1));

            local = OnePole.ar(local, \damping.kr(0!numchannels)[channel]);
            local
        };
    };
    LocalOut.ar(tank.collect(_.last) * \feedback.kr(0.5!numchannels));
    // Output mixing - now using all 4 tank stages
    wet = tank.collect { |channeltank, i|
        Mix.new([
            channeltank[0] * \tank0.kr(0.25!numchannels)[i],
            channeltank[1] * \tank1.kr(0.25!numchannels)[i],
            channeltank[2] * \tank2.kr(0.25!numchannels)[i],
            channeltank[3] * \tank3.kr(0.25!numchannels)[i]
        ])
    };
    wet = LeakDC.ar(wet);
    wet = wet * \tail.kr(1!numchannels);

    // Final mix of dry and wet
    signal = XFade2.ar(input, wet, \mix.kr(0.5!numchannels) * 2 - 1);

    Out.ar(out, signal);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
