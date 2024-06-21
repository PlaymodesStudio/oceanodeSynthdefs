d = thisProcess.nowExecutingPath.dirname;

(
SynthDef.new(\vadimfilter13, {
	arg in,out=0;
	var input,sig,freq,res,typ,filters;
	input = In.ar(in, 13);
	freq=\pitch.kr(130!13, 1/30, fixedLag:true).midicps;
	res=\res.kr(1!13);

	filters=[
		VadimFilter.ar(input,freq,res, type: 0),
		VadimFilter.ar(input,freq,res, type: 1),
		VadimFilter.ar(input,freq,res, type: 2),
		VadimFilter.ar(input,freq,res, type: 3),
		VadimFilter.ar(input,freq,res, type: 4),
		VadimFilter.ar(input,freq,res, type: 5)
	];

	sig=Select.ar(\type.kr(0!13),filters);

	Out.ar(out, sig);

}).writeDefFile(d);
)

(
SynthDef.new(\ladderfilter13, {
	arg in,out=0;
	var input,sig,freq,res,typ,overdrive,filters;
	input = In.ar(in, 13);
	freq=\pitch.kr(130!13, 1/30, fixedLag:true).midicps;
	res=\res.kr(0.5!13);
	overdrive=\drive.kr(0!13, 1/30, fixedLag: true);

	filters=[
		VALadder.ar(input,freq,res,overdrive, type: 0),
		VALadder.ar(input,freq,res,overdrive, type: 1),
		VALadder.ar(input,freq,res,overdrive, type: 2),
		VALadder.ar(input,freq,res,overdrive, type: 3),
		VALadder.ar(input,freq,res,overdrive, type: 4),
		VALadder.ar(input,freq,res,overdrive, type: 5)
	];

	sig=Select.ar(\type.kr(0!13),filters);

	Out.ar(out, sig);

}).writeDefFile(d);
)