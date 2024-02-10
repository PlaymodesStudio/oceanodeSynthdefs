(//// ampmod
SynthDef.new(\ampmod, {
	arg in, out=0;
	var input,modulated,sig,wet,dry,p,amt;
	input = In.ar(in, 78);
	amt=\strength.kr(1!78);
	p=(\pitch.kr(48!78, 0.1, fixedLag:true)).midicps;
	modulated=input*(((SinOsc.ar(p,0,1,0)+1)/2)*amt);
	modulated=modulated.tanh;
	wet=\mix.kr(0!78, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(modulated*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// ampmod
SynthDef.new(\ampmod13, {
	arg in, out=0;
	var input,modulated,sig,wet,dry,p,amt;
	input = In.ar(in, 13);
	amt=\strength.kr(1!13);
	p=(\pitch.kr(48!13, 0.1, fixedLag:true)).midicps;
	modulated=input*(((SinOsc.ar(p,0,1,0)+1)/2)*amt);
	modulated=modulated.tanh;
	wet=\mix.kr(0!13, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(modulated*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// ampmod
SynthDef.new(\ampmodmono, {
	arg in, out=0;
	var input,modulated,sig,wet,dry,p,amt;
	input = In.ar(in, 1);
	amt=\strength.kr(1!1);
	p=(\pitch.kr(48!1, 0.1, fixedLag:true)).midicps;
	modulated=input*(((SinOsc.ar(p,0,1,0)+1)/2)*amt);
	modulated=modulated.tanh;
	wet=\mix.kr(0!1, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(modulated*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)