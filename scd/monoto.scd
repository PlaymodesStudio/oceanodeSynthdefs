(//monoto78
SynthDef.new(\monoto78, {
	arg in, out=0;
	var sig,lvl=1;
	lvl=\level.kr(1!78);
	sig = In.ar(in, 1);
	sig=(sig.dup(78))*lvl;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//monoto13
SynthDef.new(\monoto13, {
	arg in, out=0;
	var sig,lvl=1;
	lvl=\level.kr(1!13);
	sig = In.ar(in, 1);
	sig=(sig.dup(13))*lvl;
	Out.ar(out, sig);
}).writeDefFile(d);
)