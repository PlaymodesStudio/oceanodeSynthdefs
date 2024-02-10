(/// multiplier
SynthDef.new(\multiplier, {
	arg in, out=0;
	var input,mult1,mult2,mult3,mult4,sig;
	input = In.ar(in, 78);
	mult1=\mul1.kr(1!78, 1/30, fixedLag:true);
	mult2=\mul2.kr(1!78, 1/30, fixedLag:true);
	mult3=\mul3.kr(1!78, 1/30, fixedLag:true);
	mult4=\mul4.kr(1!78, 1/30, fixedLag:true);
	sig=input*mult1*mult2*mult3*mult4;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// multiplier
SynthDef.new(\multiplier13, {
	arg in, out=0;
	var input,mult1,mult2,mult3,mult4,sig;
	input = In.ar(in, 13);
	mult1=\mul1.kr(1!13, 1/30, fixedLag:true);
	mult2=\mul2.kr(1!13, 1/30, fixedLag:true);
	mult3=\mul3.kr(1!13, 1/30, fixedLag:true);
	mult4=\mul4.kr(1!13, 1/30, fixedLag:true);
	sig=input*mult1*mult2*mult3*mult4;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// multiplier
SynthDef.new(\multipliermono, {
	arg in, out=0;
	var input,mult1,mult2,mult3,mult4,sig;
	input = In.ar(in, 1);
	mult1=\mul1.kr(1!1, 1/30, fixedLag:true);
	mult2=\mul2.kr(1!1, 1/30, fixedLag:true);
	mult3=\mul3.kr(1!1, 1/30, fixedLag:true);
	mult4=\mul4.kr(1!1, 1/30, fixedLag:true);
	sig=input*mult1*mult2*mult3*mult4;
	Out.ar(out, sig);
}).writeDefFile(d);
)