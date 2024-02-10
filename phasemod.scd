(//// phmod synth
SynthDef(\phmod, {
	arg out;
	var carfreq,modfreq,pmidx,sig,lv;
	carfreq=\carp.kr(48!78).midicps;
	modfreq=\modp.kr(60!78).midicps;
	pmidx=\pmindex.kr(0!78);
	sig=PMOsc.ar(carfreq,modfreq,pmidx,0,\levels.kr(0!78, 1/30, fixedLag:true),0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// phmod synth
SynthDef(\phmod13, {
	arg out;
	var carfreq,modfreq,pmidx,sig,lv;
	carfreq=\carp.kr(48!13).midicps;
	modfreq=\modp.kr(60!13).midicps;
	pmidx=\pmindex.kr(0!13);
	sig=PMOsc.ar(carfreq,modfreq,pmidx,0,\levels.kr(0!13, 1/30, fixedLag:true),0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// phmod synth
SynthDef(\phmodmono, {
	arg out;
	var carfreq,modfreq,pmidx,sig,lv;
	carfreq=\carp.kr(48!1).midicps;
	modfreq=\modp.kr(60!1).midicps;
	pmidx=\pmindex.kr(0!1);
	sig=PMOsc.ar(carfreq,modfreq,pmidx,0,\levels.kr(0!1, 1/30, fixedLag:true),0);
	Out.ar(out, sig);
}).writeDefFile(d);
)