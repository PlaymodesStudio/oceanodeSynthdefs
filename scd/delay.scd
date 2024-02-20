(// delay
SynthDef(\delay2,{
	arg in=0, out=0;
	var sig,del,dry;
	del=\delayms.kr(0!2, 1/30, fixedLag:true)/1000;
	dry = In.ar(in, 2);
	sig=DelayC.ar(dry,24,del);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(// delay
SynthDef(\delay13,{
	arg in=0, out=0;
	var sig,del,dry;
	del=\delayms.kr(0!13, 1/30, fixedLag:true)/1000;
	dry = In.ar(in, 13);
	sig=DelayC.ar(dry,24,del);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(// delay
SynthDef(\delay78,{
	arg in=0, out=0;
	var sig,del,dry;
	del=\delayms.kr(0!78, 1/30, fixedLag:true)/1000;
	dry = In.ar(in, 78);
	sig=DelayC.ar(dry,24,del);
	Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
