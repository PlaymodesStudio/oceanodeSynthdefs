(//reverb 2
SynthDef(\reverb, {
	arg in, out=0;
	var predel,revtime,lpf,hpf,mx,amp=1,dry,wet,temp,sig;
	predel=\predelay.kr(1!78);
	revtime=\time.kr(4!78);
	lpf=\lowpass.kr(100!78).midicps;
	hpf=\hipass.kr(12!78).midicps;
	mx=\mix.kr(0!78);

	dry = In.ar(in, 78);
	temp= In.ar(in, 78);

	wet=0;
	temp=DelayN.ar(temp, 1!78, predel);
	32.do {temp=AllpassL.ar(temp, 0.05!78, {Rand(0.001,0.05)}!78,revtime);
		temp=LPF.ar(temp,lpf);
		temp=HPF.ar(temp,hpf);
		wet=wet+temp;
	};
	sig=(dry*(1-mx))+(wet*mx);
	Out.ar(out,sig);
}).writeDefFile(d);
)

(//reverb 13ch
SynthDef(\reverb13, {
	arg in, out=0;
	var predel,revtime,lpf,hpf,mx,amp=1,dry,wet,temp,sig;
	predel=\predelay.kr(1!13);
	revtime=\time.kr(4!13);
	lpf=\lowpass.kr(100!13).midicps;
	hpf=\hipass.kr(12!13).midicps;
	mx=\mix.kr(0!13);

	dry = In.ar(in, 13);
	temp= In.ar(in, 13);

	wet=0;
	temp=DelayN.ar(temp, 1!13, predel);
	32.do {temp=AllpassL.ar(temp, 0.05!13, {Rand(0.001,0.05)}!13,revtime);
		temp=LPF.ar(temp,lpf);
		temp=HPF.ar(temp,hpf);
		wet=wet+temp;
	};
	sig=(dry*(1-mx))+(wet*mx);
	Out.ar(out,sig);
}).writeDefFile(d);
)

(//reverb 13ch
SynthDef(\reverbmono, {
	arg in, out=0;
	var predel,revtime,lpf,hpf,mx,amp=1,dry,wet,temp,sig;
	predel=\predelay.kr(1!1);
	revtime=\time.kr(4!1);
	lpf=\lowpass.kr(100!1).midicps;
	hpf=\hipass.kr(12!1).midicps;
	mx=\mix.kr(0!1);

	dry = In.ar(in, 1);
	temp= In.ar(in, 1);

	wet=0;
	temp=DelayN.ar(temp, 1!1, predel);
	32.do {temp=AllpassL.ar(temp, 0.05!1, {Rand(0.001,0.05)}!1,revtime);
		temp=LPF.ar(temp,lpf);
		temp=HPF.ar(temp,hpf);
		wet=wet+temp;
	};
	sig=(dry*(1-mx))+(wet*mx);
	Out.ar(out,sig);
}).writeDefFile(d);
)