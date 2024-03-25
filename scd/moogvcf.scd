d = thisProcess.nowExecutingPath.dirname;


(
SynthDef.new(\moogvcf13, {
	arg in=0,out=0;
	var input,filters,filtered,freq,res,type;
	input = In.ar(in, 13);
	freq=\pitch.kr(128!13, 0.05, fixedLag:true).midicps;
	res=\reso.kr(1!13);

	filters=[
		MoogVCF.ar(input,freq,res),
		MoogFF.ar(input,freq,res*4),
		BMoog.ar(input,freq,1-res),
		MoogLadder.ar(input,freq,res)
	];

	filtered=Select.ar(\type.kr(0),filters);
	Out.ar(out, filtered);
}).writeDefFile(d);
)
