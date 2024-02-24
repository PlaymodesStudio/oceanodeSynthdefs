(
SynthDef(\softsaturator13, {
	arg out = 0, in=0;
	var sig,dist;
	var input = In.ar(in, 2);

	var amount =\amount.kr(0!13, 0.1, fixedLag:true);
	var k = 2 * amount / (1 - amount);

	var wet=\mix.kr(0!13, 0.1, fixedLag:true);
	var dry=1-wet;

	dist = (1 + k) * input / (1 + (k * input.abs));

	sig=(input*dry)+(dist*wet);

	Out.ar(out, sig);
}).writeDefFile(d);
)


d = thisProcess.nowExecutingPath.dirname;