(//monoize78
SynthDef.new(\monoize78, {
	arg in, out=0;
	var sig,lvl=1;
	lvl=\level.kr(1, 1/30, fixedLag:true);
	sig = In.ar(in, 78)/78;
	sig=Mix.ar(sig)*lvl;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//monoize13
SynthDef.new(\monoize13, {
	arg in, out=0;
	var sig,lvl=1;
	lvl=\level.kr(1, 1/30, fixedLag:true);
	sig = In.ar(in, 13)/13;
	sig=Mix.ar(sig)*lvl;
	Out.ar(out, sig);
}).writeDefFile(d);
)