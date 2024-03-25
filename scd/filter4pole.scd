d = thisProcess.nowExecutingPath.dirname;

(
SynthDef.new(\filter4pole13, {
	arg in,out=0;
	var input,filters,filtered,freq,res,type;
	input = In.ar(in, 13);
	freq=\pitch.kr(128!13, 0.05, fixedLag:true).midicps;
	res=\q.kr(1!13);

	filters=[
		BLowPass4.ar(input,freq,res),
		BHiPass4.ar(input,freq,res),
	];

	filtered=Select.ar(\type.kr(0!13),filters);
	Out.ar(out, filtered);
}).writeDefFile(d);
)