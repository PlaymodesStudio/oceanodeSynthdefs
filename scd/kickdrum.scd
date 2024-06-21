

(//kickdrum
SynthDef(\kickdrum, {
	arg out = 0, pan = 0, amp = 1;
	var body, bodyFreq, bodyAmp;
	var waves;
	var go=\trigger.kr(0!78);
	var hi=\hifreq.kr(18000!78);
	var lo=\lopitch.kr(36!78).midicps;
	var time1=\freq1time.kr(0.035!78);
	var time2=\freq2time.kr(0.8!78);
	var curv=\freqcurve.kr(-8!78);
	var a=\attack.kr(0!78);
	var s=\sustain.kr(0.1!78);
	var r=\release.kr(0.3!78);
	var pmp=\pmpitch.kr(0!78).midicps;
	var pmidx=\pmindex.kr(0!78);
	bodyFreq = EnvGen.ar(Env([hi,hi,lo,lo], [0,time1,time2,time2], curve: curv), go);
	bodyAmp = EnvGen.ar(Env.linen(a, s, r, curve: 'cubed'), go);
	waves=[
		PMOsc.ar(bodyFreq,bodyFreq-pmp,pmidx) * bodyAmp;,
		Pulse.ar(bodyFreq)*bodyAmp
	];
	body =Select.ar(\wavetype.kr(0!78),waves);
	body=body.tanh;
	Out.ar(out, body);
}).writeDefFile(d);
)

(//kickdrum
SynthDef(\kickdrum13, {
	arg out = 0, pan = 0, amp = 1;
	var body, bodyFreq, bodyAmp;
	var waves;
	var go=\trigger.kr(0!13);
	var hi=\hifreq.kr(18000!13);
	var lo=\lopitch.kr(36!13).midicps;
	var time1=\freq1time.kr(0.035!13);
	var time2=\freq2time.kr(0.8!13);
	var curv=\freqcurve.kr(-8!13);
	var a=\attack.kr(0!13);
	var s=\sustain.kr(0.1!13);
	var r=\release.kr(0.3!13);
	var pmp=\pmpitch.kr(0!13).midicps;
	var pmidx=\pmindex.kr(0!13);
	bodyFreq = EnvGen.ar(Env([hi,hi,lo,lo], [0,time1,time2,time2], curve: curv), go);
	bodyAmp = EnvGen.ar(Env.linen(a, s, r, curve: 'cubed'), go);
	waves=[
		PMOsc.ar(bodyFreq,bodyFreq-pmp,pmidx) * bodyAmp;,
		Pulse.ar(bodyFreq)*bodyAmp
	];
	body =Select.ar(\wavetype.kr(0!13),waves);
	body=body.tanh;
	Out.ar(out, body);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


(//kickdrum
SynthDef(\kickdrummono, {
	arg out = 0, pan = 0, amp = 1;
	var body, bodyFreq, bodyAmp;
	var waves;
	var go=\trigger.kr(0!1);
	var hi=\hifreq.kr(18000!1);
	var lo=\lopitch.kr(36!1).midicps;
	var time1=\freq1time.kr(0.035!1);
	var time2=\freq2time.kr(0.8!1);
	var curv=\freqcurve.kr(-8!1);
	var a=\attack.kr(0!1);
	var s=\sustain.kr(0.1!1);
	var r=\release.kr(0.3!1);
	var pmp=\pmpitch.kr(0!1).midicps;
	var pmidx=\pmindex.kr(0!1);
	bodyFreq = EnvGen.ar(Env([hi,hi,lo,lo], [0,time1,time2,time2], curve: curv), go);
	bodyAmp = EnvGen.ar(Env.linen(a, s, r, curve: 'cubed'), go);
	waves=[
		PMOsc.ar(bodyFreq,bodyFreq-pmp,pmidx) * bodyAmp;,
		Pulse.ar(bodyFreq)*bodyAmp
	];
	body =Select.ar(\wavetype.kr(0!1),waves);
	body=body.tanh;
	Out.ar(out, body);
}).writeDefFile(d);
)