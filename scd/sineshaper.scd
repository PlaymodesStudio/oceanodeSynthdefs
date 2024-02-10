(//// sine shaper
SynthDef.new(\sineshaper, {
	arg in, out=0;
	var input,shaped,sig,wet,dry;
	input = In.ar(in, 78);
	shaped=(input*\level.kr(1!78, 0.1, fixedLag:true)).sin;
	wet=\mix.kr(0!78, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(shaped*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// sine shaper
SynthDef.new(\sineshaper13, {
	arg in, out=0;
	var input,shaped,sig,wet,dry;
	input = In.ar(in, 13);
	shaped=(input*\levels.kr(0!13, 0.1, fixedLag:true)).sin;
	wet=\mix.kr(0!13, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(shaped*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// sine shaper
SynthDef.new(\sineshapermono, {
	arg in, out=0;
	var input,shaped,sig,wet,dry;
	input = In.ar(in, 1);
	shaped=(input*\level.kr(1!1, 0.1, fixedLag:true)).sin;
	wet=\mix.kr(0!1, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(shaped*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)