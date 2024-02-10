

(///// GranularSampler
SynthDef(\grainsampler,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain,dur;
		t=\trigger.kr(0!78);
		gain=\levels.kr(0!78, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!78);
		spd=\speed.kr(1!78);
		start=\startpos.kr(0!78);
		dur=\grainsize.kr(0.1!78);
		signal=GrainBuf.ar(1, t, dur, buf, spd, start,2,0,-1,1024)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

(///// GranularSampler
SynthDef(\grainsampler13,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain,dur;
		t=\trigger.kr(0!13);
		gain=\levels.kr(0!13, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!13);
		spd=\speed.kr(1!13);
		start=\startpos.kr(0!13);
		dur=\grainsize.kr(0.1!13);
		signal=GrainBuf.ar(1, t, dur, buf, spd, start,2,0,-1,1024)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

(///// GranularSampler
SynthDef(\grainsamplermono,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain,dur;
		t=\trigger.kr(0!1);
		gain=\levels.kr(0!1, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!1);
		spd=\speed.kr(1!1);
		start=\startpos.kr(0!1);
		dur=\grainsize.kr(0.1!1);
		signal=GrainBuf.ar(1, t, dur, buf, spd, start,2,0,-1,1024)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)