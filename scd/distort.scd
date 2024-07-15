d = thisProcess.nowExecutingPath.dirname;

(//distortion
SynthDef.new(\distort, {
	arg in, out=0;
	var input,distort,distortions,type,sig,wet,dry,distamp,tp;
	input = In.ar(in, 78);
	input=LeakDC.ar(input);

	distamp=(\pregain.kr(0.2!78, 0.1, fixedLag:true).pow(2)*80); //param1 preGain

	distortions=[
		(input*distamp).distort,
		(input*distamp).softclip,
		(input*distamp).clip2,
		(input*distamp).fold2,
		(input*distamp).wrap2,
		(1 + (2 * (((distamp/80)*2)-1) / (1 - (((distamp/80)*2)-1)))) * input / (1 + ((2 * (((distamp/80)*2)-1) / (1 - (((distamp/80)*2)-1))) * input.abs));
	];

	tp=\type.kr(0!78); //param2 Type
	distort=Select.ar(tp,distortions);

	wet=\mix.kr(0!78, 0.1, fixedLag:true); //param3 Mix
	dry=1-wet;
	sig=(input*dry)+(distort*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//distortion
SynthDef.new(\distort13, {
	arg in, out=0;
	var input,distort,distortions,type,sig,wet,dry,distamp,tp;
	input = In.ar(in, 13);
	input=LeakDC.ar(input);

	distamp=(\pregain.kr(0.2!13, 0.1, fixedLag:true).pow(2)*80); //param1 preGain

	distortions=[
		(input*distamp).distort,
		(input*distamp).softclip,
		(input*distamp).clip2,
		(input*distamp).fold2,
		(input*distamp).wrap2,
		(1 + (2 * (((distamp/80)*2)-1) / (1 - (((distamp/80)*2)-1)))) * input / (1 + ((2 * (((distamp/80)*2)-1) / (1 - (((distamp/80)*2)-1))) * input.abs));
	];

	tp=\type.kr(0!13); //param2 Type
	distort=Select.ar(tp,distortions);

	wet=\mix.kr(0!13, 0.1, fixedLag:true); //param3 Mix
	dry=1-wet;
	sig=(input*dry)+(distort*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//distortion
SynthDef.new(\distortmono, {
	arg in, out=0;
	var input,distort,distortions,type,sig,wet,dry,distamp,tp;
	input = In.ar(in, 1);
	input=LeakDC.ar(input);

	distamp=(\pregain.kr(0.2!1, 0.1, fixedLag:true).pow(2)*80); //param1 preGain

	distortions=[
		(input*distamp).distort,
		(input*distamp).softclip,
		(input*distamp).clip2,
		(input*distamp).fold2,
		(input*distamp).wrap2,
		(1 + (2 * (((distamp/80)*2)-1) / (1 - (((distamp/80)*2)-1)))) * input / (1 + ((2 * (((distamp/80)*2)-1) / (1 - (((distamp/80)*2)-1))) * input.abs));
	];

	tp=\type.kr(0!1); //param2 Type
	distort=Select.ar(tp,distortions);

	wet=\mix.kr(0!1, 0.1, fixedLag:true); //param3 Mix
	dry=1-wet;
	sig=(input*dry)+(distort*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)