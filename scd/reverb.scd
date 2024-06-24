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
SynthDef(\reverb6, {
	arg in, out=0;
	var predel,revtime,lpf,hpf,mx,amp=1,dry,wet,temp,sig;
	predel=\predelay.kr(1!6);
	revtime=\time.kr(4!6);
	lpf=\lowpass.kr(100!6).midicps;
	hpf=\hipass.kr(12!6).midicps;
	mx=\mix.kr(0!6);

	dry = In.ar(in, 6);
	temp= In.ar(in, 6);

	wet=0;
	temp=DelayN.ar(temp, 1!6, predel);
	32.do {temp=AllpassL.ar(temp, 0.05!6, {Rand(0.001,0.05)}!6,revtime);
		temp=LPF.ar(temp,lpf);
		temp=HPF.ar(temp,hpf);
		wet=wet + temp;
	};
	sig=(dry*(1-mx))+(wet*mx);
	Out.ar(out,sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


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

(
SynthDef(\jpverb13, {
	arg in = 0, out = 0;
	var source, sig, revtime = 1, damp = 0, size = 1, early = 0.707, low, mid, high, lowcut, highcut, modDepth, modFreq,mx;

	revtime=\time.kr(1!13, 1/30, fixedLag: true);
	damp=\damp.kr(0!13, 1/30, fixedLag: true);
	size=\size.kr(1!13, 1/30, fixedLag: true);
	early=\early.kr(0.7, 1/30, fixedLag: true);
	low=\lowtime.kr(1!13, 1/30, fixedLag: true);
	mid=\midtime.kr(1!13, 1/30, fixedLag: true);
	high=\hitime.kr(1!13, 1/30, fixedLag: true);
	lowcut=\lowcut.kr(200!13, 1/30, fixedLag: true);
	highcut=\hicut.kr(5000!13, 1/30, fixedLag: true);
	modDepth=\moddepth.kr(0.1!13, 1/30, fixedLag: true);
	modFreq=\modfreq.kr(2!13, 1/30, fixedLag: true);
	mx=\mix.kr(0!1);

	source = In.ar (in, 13);
	sig = 0!13 + JPverb.ar (source, revtime, damp, size, early, modDepth, modFreq, low, mid, high, lowcut, highcut);
	sig=(source*(1-mx))+(sig*mx);
	Out.ar (out, sig);
}).writeDefFile(d);
)

(
SynthDef(\greyholereverb13, {
	arg in = 0, out = 0;
	var source, sig, revtime = 1, damp = 0, size = 1, diff, modDepth, modFreq,feed,mx,lowp,hip;

	revtime=\time.kr(1!13, 1/30, fixedLag: true); //0-60
	damp=\damp.kr(0!13, 1/30, fixedLag: true); //0.5-5
	size=\size.kr(1!13, 1/30, fixedLag: true); //0-1
	diff=\diff.kr(0.7, 1/30, fixedLag: true); //0-3
	feed=\feedback.kr(0.9!13, 1/30, fixedLag: true); //0-1
	modDepth=\moddepth.kr(0.1!13, 1/30, fixedLag: true); //0-1
	modFreq=\modfreq.kr(2!13, 1/30, fixedLag: true); //0-10
	mx=\mix.kr(0!1); //0-1
	lowp=\lopass.kr(130!13).midicps;
	hip=\hipass.kr(10!13).midicps;
	source = In.ar (in, 13);
	sig = Greyhole.ar (source, revtime, damp, size, diff, feed, modDepth, modFreq);
	sig=LPF.ar(sig,lowp);
	sig=HPF.ar(sig,hip);
	sig=(source*(1-mx))+(sig*mx);
	Out.ar (out, sig);
}).writeDefFile(d);
)
d = thisProcess.nowExecutingPath.dirname;
