(
SynthDef(\wavefold13, {
    arg out = 0, in=0;
	var dist,sig,wet,dry;
	var amt=1-(\amount.kr(0!13, 0.1, fixedLag:true));
	in = In.ar(in, 13);
	dist = Fold.ar(in, amt.neg, amt)*(1/amt);

	wet=\mix.kr(0!13, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(in*dry)+(dist*wet);

    Out.ar(out, sig);
},
).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

