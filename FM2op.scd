(///fm synth
SynthDef(\fm, {
	arg p, mR,mRf, cR,cRf, idx=1, amp, out=0;
	var car, mod, fb,sig;
	p=\pitch.kr(36!78).midicps; //param1
	amp=\levels.kr(0!78, 1/30, fixedLag:true); //param2
	mR=\mratio.kr(1!78)+\mratiofine.kr(0!78);//param3
	cR=\cratio.kr(1!78)+\cratiofine.kr(0!78);//param4
	idx=\index.kr(1!78);//param5
	fb=\mfeedback.kr(0!78);
	mod = SinOscFB.ar(p * mR, fb, mul:p * mR * idx);
	car=[
		SinOsc.ar(p * cR + mod) * amp,
		Saw.ar(p * cR + mod) * amp,
		LFTri.ar(p * cR + mod) * amp,
		Pulse.ar(p * cR + mod) * amp
	];
	sig=Select.ar(\mwave.kr(0!78),car);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(///fm synth
SynthDef(\fm13, {
	arg p, mR,mRf, cR,cRf, idx=1, amp, out=0;
	var car, mod, fb,sig;
	p=\pitch.kr(36!13).midicps; //param1
	amp=\levels.kr(0!13, 1/30, fixedLag:true); //param2
	mR=\mratio.kr(1!13)+\mratiofine.kr(0!13);//param3
	cR=\cratio.kr(1!13)+\cratiofine.kr(0!13);//param4
	idx=\index.kr(1!13);//param5
	fb=\mfeedback.kr(0!13);
	mod = SinOscFB.ar(p * mR, fb, mul:p * mR * idx);
	car=[
		SinOsc.ar(p * cR + mod) * amp,
		Saw.ar(p * cR + mod) * amp,
		LFTri.ar(p * cR + mod) * amp,
		Pulse.ar(p * cR + mod) * amp
	];
	sig=Select.ar(\mwave.kr(0!13),car);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(///fm synth
SynthDef(\fmmono, {
	arg p, mR,mRf, cR,cRf, idx=1, amp, out=0;
	var car, mod, fb,sig;
	p=\pitch.kr(36!1).midicps; //param1
	amp=\levels.kr(0!1, 1/30, fixedLag:true); //param2
	mR=\mratio.kr(1!1)+\mratiofine.kr(0!1);//param3
	cR=\cratio.kr(1!1)+\cratiofine.kr(0!1);//param4
	idx=\index.kr(1!1);//param5
	fb=\mfeedback.kr(0!1);
	mod = SinOscFB.ar(p * mR, fb, mul:p * mR * idx);
	car=[
		SinOsc.ar(p * cR + mod) * amp,
		Saw.ar(p * cR + mod) * amp,
		LFTri.ar(p * cR + mod) * amp,
		Pulse.ar(p * cR + mod) * amp
	];
	sig=Select.ar(\mwave.kr(0!1),car);
	Out.ar(out, sig);
}).writeDefFile(d);
)