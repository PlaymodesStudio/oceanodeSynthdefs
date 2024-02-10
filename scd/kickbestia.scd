d = thisProcess.nowExecutingPath.dirname;

(//kickdrum
SynthDef(\kickdrumB, {
	arg out=0;
	var body, bodyfreq, bodyamp;
	var go=\trigger.kr(0!78);
	var p=\pitch.kr(36!78).midicps;
	var curvp=\pitchcurve.kr(-4!78);
	var curva=\ampcurve.kr(-4!78);
	var pdec=\pitchdecay.kr(4!78);
	var adec=\ampdecay.kr(4!78);
	var tune=\hitune.kr(300!78);
	var harm=\harmonics.kr(40!78);

	bodyfreq=EnvGen.ar(Env([0,tune,p], [0,pdec], curve: curvp), go);
	bodyamp=EnvGen.ar(Env([0,1,0], [0,0,adec], curve: curva), go);
	body=LFTri.ar(bodyfreq)*harm*bodyamp;
	body=body.tanh;
	Out.ar(out, body);
}).writeDefFile(d);
)

Env([0,1,0], [0,4], curve: -4).plot;
Env([0,300,60], [0,4], curve: -4).plot;

Synth(\kickdrumB, [\go,1]);