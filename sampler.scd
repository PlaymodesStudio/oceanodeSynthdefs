

(// samples
SynthDef(\sampler,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain;
		t=\trigger.kr(0!78);
		gain=\levels.kr(0!78, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!78);
		spd=\speed.kr(1!78);
		bucle=\loop.kr(0!78);
		start=\startpos.kr(0!78)*BufFrames.kr(buf);
		signal=PlayBuf.ar(1, buf, spd, t, start,bucle)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

(// samples
SynthDef(\sampler13,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain;
		t=\trigger.kr(0!13);
		gain=\levels.kr(0!13, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!13);
		spd=\speed.kr(1!13);
		bucle=\loop.kr(0!13);
		start=\startpos.kr(0!13)*BufFrames.kr(buf);
		signal=PlayBuf.ar(1, buf, spd, t, start,bucle)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

(// samples
SynthDef(\samplermono,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain;
		t=\trigger.kr(0!1);
		gain=\levels.kr(0!1, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!1);
		spd=\speed.kr(1!1);
		bucle=\loop.kr(0!1);
		start=\startpos.kr(0!1)*BufFrames.kr(buf);
		signal=PlayBuf.ar(1, buf, spd, t, start,bucle)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)