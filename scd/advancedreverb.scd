(
SynthDef(\sin, {
	arg freq = 440, amp = 0.25, out = 0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.ar(Env.perc(0.001, 0.14), doneAction:2);
	sig = sig * env * amp ! 2;
	Out.ar(out, sig);
}).add;
)


//esta es la que mola
(
SynthDef(\schroedereverb13, {
    arg in=0, out=0;
    var nch = 13;
    var mix=\mix.kr(0.3!nch), predelay=\predelay.kr(0.001),
    decayTime=\decay.kr(0.6), diffusion=\diffusion.kr(0.07),
    damping=\lopass.kr(130).midicps, hipass=\hipass.kr(12).midicps,
    blendOffset=\blendoff.kr(0.1), blendScale=\blendscale.kr(0.9); // New blend controls
    var sig, wet, temp, predelayed, early, blend;
    sig = In.ar(in, nch);
    // Predelay
    predelayed = DelayN.ar(sig, 1, predelay);
    // Initial diffusion
    temp = predelayed;
    4.do { |i|
        temp = AllpassC.ar(temp, 0.05, {Rand(0.001, 0.05) * decayTime.min(1)}!nch, 0.1 * decayTime.min(1));
    };
    // Early reflections
    early = Mix.fill(7, {
        var delay = Rand(0.001, 0.02);
        DelayC.ar(sig, 0.02, delay) * (1 - (delay / 0.02))
    });
    // Tank reverb structure (parallel comb filters into series allpass filters)
    wet = Mix.fill(7, {
        CombC.ar(temp, 0.1, {Rand(0.01, 0.099) * decayTime.min(1)}!nch, decayTime * Rand(0.9, 1.1))
    });
    // Further diffusion and density
    5.do { |i|
        wet = AllpassC.ar(wet, 0.050, {Rand(0.01, 0.05) * decayTime.min(1)}!nch, decayTime * diffusion * (1 - (i * 0.03)));
    };
    // Blend early reflections and late reverb based on decay time
    blend = ((decayTime - blendOffset).clip(0, 1) / blendScale).clip(0, 1);
    wet = (early * (1 - blend)) + (wet * blend);
    // Damping (low-pass filter)
    wet = LPF.ar(wet, damping);
    // Remove DC offset and very low frequencies
    wet = LeakDC.ar(wet);
    wet = HPF.ar(wet, hipass);
    wet = Sanitize.ar(wet);
    // Mix dry and wet signals
    sig = XFade2.ar(sig, wet, mix * 2 - 1);
    Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


~r = Synth(\schroedereverb13, [in: ~bus, mix: 0.2]);

Synth(\sin, [freq: exprand(180, 2500), out: ~bus]);

~r.free;