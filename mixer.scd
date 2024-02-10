(//// mixer
SynthDef.new(\mixer, {
	arg in=0, in2=0, out=0;
	var sig1, sig2, finalsig;
	sig1 = In.ar(in, 78)*\levels1.kr(0.5!78, 1/30, fixedLag:true);
	sig2 = In.ar(in2, 78)*\levels2.kr(0.5!78, 1/30, fixedLag:true);
	finalsig=sig1+sig2;
	Out.ar(out, finalsig);
}).writeDefFile(d);
)

(//// mixer
SynthDef.new(\mixer13, {
	arg in=0, in2=0, out=0;
	var sig1, sig2, finalsig;
	sig1 = In.ar(in, 13)*\levels1.kr(0.5!13, 1/30, fixedLag:true);
	sig2 = In.ar(in2, 13)*\levels2.kr(0.5!13, 1/30, fixedLag:true);
	finalsig=sig1+sig2;
	Out.ar(out, finalsig);
}).writeDefFile(d);
)

(//// mixer
SynthDef.new(\mixermono, {
	arg in=0, in2=0, out=0;
	var sig1, sig2, finalsig;
	sig1 = In.ar(in, 1)*\levels1.kr(0.5!1, 1/30, fixedLag:true);
	sig2 = In.ar(in2, 1)*\levels2.kr(0.5!1, 1/30, fixedLag:true);
	finalsig=sig1+sig2;
	Out.ar(out, finalsig);
}).writeDefFile(d);
)
