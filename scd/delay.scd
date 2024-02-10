(// delay
SynthDef(\delay,{
	arg in=0, out=0;
	var sig,del,dry;
	del=\delay.kr(1!2, 1/30, fixedLag:true);
	dry = In.ar(in, 2);
	sig=DelayC.ar(dry,24,del);
	Out.ar(out, sig);
}).writeDefFile(d);
)