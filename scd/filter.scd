//multimode filter
(
SynthDef.new(\filter, {
	arg in,out=0;
	var input,filters,filtered,freq,res,type;
	input = In.ar(in, 78);
	freq=\pitch.kr(128!78, 0.05, fixedLag:true).midicps;
	res=\q.kr(1!78);

	filters=[
		RLPF.ar(input,freq,res,1,0),
		RHPF.ar(input,freq,res,1,0),
		BPF.ar(input,freq,res,1,0),
		BRF.ar(input,freq,res,1,0),
		BPeakEQ.ar(input,freq,1,res*12,1,0)
	];

	filtered=Select.ar(\type.kr(0!78),filters);
	Out.ar(out, filtered);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef.new(\filter48, {
	arg in,out=0;
	var input,filters,filtered,freq,res,type;
	input = In.ar(in, 48);
	freq=\pitch.kr(128!48, 0.05, fixedLag:true).midicps;
	res=\q.kr(1!48);

	filters=[
		RLPF.ar(input,freq,res,1,0),
		RHPF.ar(input,freq,res,1,0),
		BPF.ar(input,freq,res,1,0),
		BRF.ar(input,freq,res,1,0),
		BPeakEQ.ar(input,freq,1,res*12,1,0)
	];

	filtered=Select.ar(\type.kr(0!48),filters);
	Out.ar(out, filtered);
}).writeDefFile(d);
)

(
SynthDef.new(\filter13, {
	arg in,out=0;
	var input,filters,filtered,freq,res,type;
	input = In.ar(in, 13);
	freq=\pitch.kr(128!13, 0.05, fixedLag:true).midicps;
	res=\q.kr(1!13);

	filters=[
		RLPF.ar(input,freq,res,1,0),
		RHPF.ar(input,freq,res,1,0),
		BPF.ar(input,freq,res,1,0),
		BRF.ar(input,freq,res,1,0),
		BPeakEQ.ar(input,freq,1,res*12,1,0)
	];

	filtered=Select.ar(\type.kr(0!13),filters);
	Out.ar(out, filtered);
}).writeDefFile(d);
)

(
SynthDef.new(\filter6, {
	arg in,out=0;
	var input,filters,filtered,freq,res,type;
	input = In.ar(in, 6);
	freq=\pitch.kr(128!6, 0.05, fixedLag:true).midicps;
	res=\q.kr(1!6);

	filters=[
		RLPF.ar(input,freq,res,1,0),
		RHPF.ar(input,freq,res,1,0),
		BPF.ar(input,freq,res,1,0),
		BRF.ar(input,freq,res,1,0),
		BPeakEQ.ar(input,freq,1,res*12,1,0)
	];

	filtered=Select.ar(\type.kr(0!6),filters);
	Out.ar(out, filtered);
}).writeDefFile(d);
)



(
SynthDef.new(\filtermono, {
	arg in,out=0;
	var input,filters,filtered,freq,res,type;
	input = In.ar(in, 1);
	freq=\pitch.kr(128!1, 0.05, fixedLag:true).midicps;
	res=\q.kr(1!1);

	filters=[
		RLPF.ar(input,freq,res,1,0),
		RHPF.ar(input,freq,res,1,0),
		BPF.ar(input,freq,res,1,0),
		BRF.ar(input,freq,res,1,0),
		BPeakEQ.ar(input,freq,1,res*12,1,0)
	];

	filtered=Select.ar(\type.kr(0!1),filters);
	Out.ar(out, filtered);
}).writeDefFile(d);
)