(
SynthDef.new(\fmperc, {
    var sig, freq, car1, car2, mod1, mod2, mod3;
    var iscale, iEnv1, iEnv2, icurve, index1, index2;
    var m1Ratio, m2Ratio, m3Ratio, env;
    var fb, atk, rel, detune, mix, gate;
    //ctrl
	freq = \freq.kr(60);
    index1 = \index1.kr(1);
    index2 = \index2.kr(2);
    iscale = \iscale.kr(0.04);
    icurve = \icurve.kr(-8);
    atk = \atk.kr(0);
    rel = \rel.kr(1);
    detune = 2**(\detune.kr(10) / 1200);
    mix = \mix.kr(0.5);
    m1Ratio = \m1ratio.kr(1);
    m2Ratio = \m2ratio.kr(12);
	m3Ratio = \m3ratio.kr(12);
	gate=\gate.kr(0);
    //index of modulation
    iEnv1 = EnvGen.kr(Env.perc(\i1atk.kr(0.01), \i1rel.kr(0.1) * rel, icurve), gate: gate) * index1 * iscale;
    iEnv2 = EnvGen.kr(Env.perc(\i2atk.kr(0.005), \i2rel.kr(1) * rel, icurve), gate: gate) * index2 * iscale;
    //amplitude envelope
    env = EnvGen.kr(Env.perc(atk, rel, curve: icurve), gate: gate);
    //modulator/carrier
    fb = LocalIn.ar(2) * \feedback.kr(0);
    //fb = Rotate2.ar(fb[0], fb[1], LFNoise2.ar(0.25) * \fbmod.kr(0.25));
    fb = Rotate2.ar(fb[0], fb[1], env.linlin(0, 1, -1 , 1) * \fbmod.kr(0.5));

    mod1 = SinOscFB.ar(freq * m1Ratio, \mod1fb.kr(0)) * freq * m1Ratio * iEnv1;
    mod2 = SinOscFB.ar(freq * m2Ratio, \mod2fb.kr(0)) * freq * m2Ratio * iEnv1;
    mod3 = SinOscFB.ar([freq, freq * detune] * (m3Ratio + mod2 + mod1 + fb), \mod3b.kr(0)) * freq * m3Ratio * iEnv2;
    car1 = SinOscFB.ar([freq, freq * detune] * \carratio.kr(0.5) + mod3, \carfb.kr(0)) * env;
    car2 = mod3 * (index1 * iscale * m1Ratio * index2 * m2Ratio * m3Ratio * freq).reciprocal * env;
    sig = Splay.ar([SelectX.ar(mix ,[car1[0], car2[0]]), SelectX.ar(mix,[car1[1], car2[1]])]);

    sig = (sig * \drive.kr(0).dbamp).tanh;

    LocalOut.ar(LeakDC.ar(mod1+mod2+mod3+car1, coef: 0.995));
    sig = LeakDC.ar(sig, coef: 0.995);
    sig = Balance2.ar(sig[0],sig[1], \pan.kr(0));
    sig = sig * \gain.kr(0).dbamp;
    Out.ar(\out.kr(0), sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
