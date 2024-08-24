
(// echofeed
SynthDef(\echo,{
	arg in=0, out=0;
	var filters=0,fb,del,cut,res,selfilt,sig,mx,dry,feedback,wet,ing;
	fb=\feed.kr(0.5!78);
	del=\delay.kr(0.2!78, 1/30, fixedLag:true);
	cut=\cutoff.kr(60!78).midicps;
	res=\resonance.kr(0.2!78);
	selfilt=\filtertype.kr(0!78);
	mx=\mix.kr(0!78);
	ing=\inputgain.kr(1!78);

	dry = In.ar(in, 78);
	feedback = LocalIn.ar(78);
	wet = LeakDC.ar(feedback*fb + (dry*ing));

	filters=[
		RLPF.ar(wet,cut,1-res,1,0),
		RHPF.ar(wet,cut,1-res,1,0),
		BPF.ar(wet,cut,1-res,1,0),
		BPeakEQ.ar(wet,cut,1,res*12,1,0)
	];

	wet=Select.ar(selfilt,filters);
	LocalOut.ar(DelayC.ar(wet, 2, del));

	sig=XFade2.ar(dry,wet,mx*2-1,1!78);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(// echofeed 13ch
SynthDef(\echo13,{
	arg in=0, out=0;
	var filters=0,fb,del,cut,res,selfilt,sig,mx,dry,feedback,wet,ing;
	fb=\feed.kr(0.5!13);
	del=\delay.kr(0.2!13, 1/30, fixedLag:true);
	cut=\cutoff.kr(60!13, 1/30, fixedLag:true).midicps;
	res=\resonance.kr(0.2!13);
	selfilt=\filtertype.kr(0!13);
	mx=\mix.kr(0!13);
	ing=\inputgain.kr(1!13, 1/30, fixedLag:true);

	dry = In.ar(in, 13);
	feedback = LocalIn.ar(13);
	wet = LeakDC.ar(feedback*fb + (dry*ing));

	filters=[
		RLPF.ar(wet,cut,1-res,1,0),
		RHPF.ar(wet,cut,1-res,1,0),
		BPF.ar(wet,cut,1-res,1,0),
		BPeakEQ.ar(wet,cut,1,res*12,1,0)
	];

	wet=Select.ar(selfilt,filters);
	LocalOut.ar(DelayC.ar(wet, 2, del));

	sig=XFade2.ar(dry,wet,mx*2-1,1!13);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(// echofeed 2ch
SynthDef(\echo2,{
	arg in=0, out=0;
	var filters=0,fb,del,cut,res,selfilt,sig,mx,dry,feedback,wet,ing;
	fb=\feed.kr(0.5!2);
	del=\delay.kr(0.2!2, 1/30, fixedLag:true);
	cut=\cutoff.kr(60!2, 1/30, fixedLag:true).midicps;
	res=\resonance.kr(0.2!2);
	selfilt=\filtertype.kr(0!2);
	mx=\mix.kr(0!2);
	ing=\inputgain.kr(1!2, 1/30, fixedLag:true);

	dry = In.ar(in, 2);
	feedback = LocalIn.ar(2);
	wet = LeakDC.ar(feedback*fb + (dry*ing));

	filters=[
		RLPF.ar(wet,cut,1-res,1,0),
		RHPF.ar(wet,cut,1-res,1,0),
		BPF.ar(wet,cut,1-res,1,0),
		BPeakEQ.ar(wet,cut,1,res*12,1,0)
	];

	wet=Select.ar(selfilt,filters);
	LocalOut.ar(DelayC.ar(wet, 2, del));

	sig=XFade2.ar(dry,wet,mx*2-1,1!2);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(// echofeed 1ch
SynthDef(\echomono,{
	arg in=0, out=0;
	var filters=0,fb,del,cut,res,selfilt,sig,mx,dry,feedback,wet,ing;
	fb=\feed.kr(0.5!1);
	del=\delay.kr(0.2!1, 1/30, fixedLag:true);
	cut=\cutoff.kr(60!1, 1/30, fixedLag:true).midicps;
	res=\resonance.kr(0.2!1);
	selfilt=\filtertype.kr(0!1);
	mx=\mix.kr(0!1);
	ing=\inputgain.kr(1!1, 1/30, fixedLag:true);

	dry = In.ar(in, 1);
	feedback = LocalIn.ar(1);
	wet = LeakDC.ar(feedback*fb + (dry*ing));

	filters=[
		RLPF.ar(wet,cut,1-res,1,0),
		RHPF.ar(wet,cut,1-res,1,0),
		BPF.ar(wet,cut,1-res,1,0),
		BPeakEQ.ar(wet,cut,1,res*12,1,0)
	];

	wet=Select.ar(selfilt,filters);
	LocalOut.ar(DelayC.ar(wet, 2, del));

	sig=XFade2.ar(dry,wet,mx*2-1,1!1);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(// feedback 13ch
SynthDef(\delayfeed13,{
	arg in=0, out=0;
	var fb,del,sig,mx,dry,feedback,grainsz,pitchsh,delmod,modgain;
	fb=\feed.kr(1!13, 1/30, fixedLag:true);
	del=\delay.kr(0.05!13, 1/30, fixedLag:true);
	mx=\mix.kr(0!13, 1/30, fixedLag:true);
	grainsz= \grainsize.kr(0.1!13, 1/30, fixedLag:true);
	pitchsh=\pitchshift.kr(0.5!13, 1/30, fixedLag:true);
	modgain=\delmodgain.kr(1!13,1/30, fixedLag:true);
	delmod=((LFNoise2.ar(0.3!13) * 1e-3) + (LFNoise2.ar(1!13) * 1e-4))*modgain;

	dry = In.ar(in, 13);
	feedback = dry+ LocalIn.ar(13);
	feedback=DelayC.ar(feedback, 1, del+delmod);
	feedback=feedback+PitchShift.ar(feedback, grainsz, pitchsh);
	feedback = LeakDC.ar(feedback*fb);
	feedback = feedback.tanh;
	feedback = feedback * -15.dbamp;

	LocalOut.ar(feedback);
	sig=XFade2.ar(dry,feedback,mx*2-1,1!13);
	Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
