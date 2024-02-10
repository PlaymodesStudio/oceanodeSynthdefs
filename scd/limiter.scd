(/// Limiter
SynthDef.new(\limiter, {
	arg in, out=0,level=1;
	var input,sig;
	input = In.ar(in, 78);
	sig=Limiter.ar(input,level,0.01)*level.reciprocal;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// Limiter 13ch
SynthDef.new(\limiter13, {
	arg in, out=0,level=1;
	var input,sig;
	input = In.ar(in, 13);
	sig=Limiter.ar(input,level,0.01)*level.reciprocal;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// Limiter 1ch
SynthDef.new(\limitermono, {
	arg in, out=0,level=1;
	var input,sig;
	input = In.ar(in, 1);
	sig=Limiter.ar(input,level,0.01)*level.reciprocal;
	Out.ar(out, sig);
}).writeDefFile(d);
)