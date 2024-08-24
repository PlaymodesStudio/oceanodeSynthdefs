(
SynthDef(\fm, {
    arg out=0;
	var freq=28.midicps,
	mRatio=1,
	cRatio=1,
	index=1,
	iScale=5,
    amp=0.2,
	atk=0.01,
	rel=3, cAtk=0.01,
	cRel=(-4),
	pan=0;
    var car, mod, env, iEnv;
    iEnv = EnvGen.kr(
        Env.new(
            [index, index * iScale, index],
            [atk, rel],
            [cAtk, cRel]
        )
    );
    env = EnvGen.kr(
        Env.perc(atk, rel, curve:[cAtk, cRel]),
        doneAction:2
    );
    mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio * iEnv);
    car = SinOsc.ar(freq * cRatio + mod) * env * amp;
    car = Pan2.ar(car, pan);
    Out.ar(out, car);
}).play;
)

Synth(\fm, [\freq, 35.midicps, \rel, 4, \index, 20, \iScale, 0.05, \mRatio, 0.5]);
