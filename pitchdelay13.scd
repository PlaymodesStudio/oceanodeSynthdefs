(
SynthDef(\pitchdelay,{
	arg in=0, out=0;
	var filters=0,fb,del,cut,res,selfilt,sig,mx,dry,feedback,wet,ing;
	fb=\feed.kr(0.5!13);
	del=VarLag.kr(\pitch.kr(36!13).midicps.reciprocal,1/30);
	cut=VarLag.kr(\cutoff.kr(60!13).midicps,1/30);
	res=\resonance.kr(0.2!13);
	selfilt=\filtertype.kr(0!13);
	mx=\mix.kr(0!13);
	ing=VarLag.kr(\inputgain.kr(1!13),1/30);

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