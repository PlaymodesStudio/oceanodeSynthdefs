d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\cymbal13, {
    arg out=0;
    var nch=13;
	var amp=\amp.kr(0.5!nch);
    var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;
	var minfreq=\minfreq.kr(300!nch);
	var maxfreq=\maxfreq.kr(20000!nch);
    var maxResonators=100;
	var locut=\locut.kr(20000!nch);
	var hicut=\hicut.kr(10000!nch);
	var time=\time.kr(5!nch);
	var thwacklevel=\thwacklevel.kr(1!nch);
	var resolevels=\resolevel.kr(1!nch);
	var lodrilevel=\lodrivelevel.kr(2!nch);
	var att=\att.kr(1!nch);
	var gate=\gate.kr(0!nch);
	var activeRes=\resonum.kr(100!nch);

    // Generate frequencies for each channel
    freqs = nch.collect({
        Array.fill(maxResonators, {
            exprand(minfreq[0], maxfreq[0])
        })
    });

    // Generate per-channel signals
    res = nch.collect({ |chan|
        var chanRes;

        // Generate envelopes for this channel
        locutoffenv = EnvGen.ar(Env.perc(0.5*att[chan], time[chan]), gate[chan]) * locut[chan] + 10;
        lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);

        hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1*att[chan], time[chan]/2.5), gate[chan]) * hicut[chan]);
        hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
        hidriver = hidriver * EnvGen.ar(Env.perc(1*att[chan], time[chan]/1.6, 0.25), gate[chan]);

        thwack = EnvGen.ar(Env.perc(0.001*att[chan], 0.001, thwacklevel[chan]), gate[chan]);

        // Sum resonators for this channel
        chanRes = Mix.fill(maxResonators, { |i|
            var isActive = i < activeRes[chan];
            Ringz.ar(
                lodriver + hidriver + thwack,
                freqs[chan][i],
                time[chan]
            ) * isActive.asInteger
        }) / maxResonators;

        // Mix for this channel
        ((chanRes * resolevels[chan]) + (lodriver * lodrilevel[chan]) + thwack) * amp[chan]
    });

    Out.ar(out, res);
}).writeDefFile(d);
)
