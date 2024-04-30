(//phase invert. generates a click without really discontinuing the signal
SynthDef.new(\phaseinvert13, {
	arg out=0, in=0;
	var input, sel, finalsig;

	input=In.ar(in,13);

	sel=[
		input,
		input * -1.0
	];

	finalsig=Select.ar(\invert.kr(0!13),sel);
	Out.ar(out, finalsig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
