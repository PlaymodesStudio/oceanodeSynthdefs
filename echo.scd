
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