

(//kickdrum
SynthDef(\kickdrumb, {
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

	bodyfreq=(EnvGen.ar(Env.perc(0.01, pdec, 1,curvp), go)*tune)+p;
	bodyamp=EnvGen.ar(Env.perc(0.01, adec, 1,curva), go)*harm;
	body=LFTri.ar(bodyfreq,0,bodyamp);
	body=body.tanh;
	Out.ar(out, body);
}).writeDefFile(d);
)

(//kickdrum
SynthDef(\kickdrumb13, {
	arg out=0;
	var body, bodyfreq, bodyamp;
	var go=\trigger.kr(0!13);
	var p=\pitch.kr(36!13).midicps;
	var curvp=\pitchcurve.kr(-4!13);
	var curva=\ampcurve.kr(-4!13);
	var pdec=\pitchdecay.kr(4!13);
	var adec=\ampdecay.kr(4!13);
	var tune=\hitune.kr(300!13);
	var harm=\harmonics.kr(40!13);

	bodyfreq=(EnvGen.ar(Env.perc(0.01, pdec, 1,curvp), go)*tune)+p;
	bodyamp=EnvGen.ar(Env.perc(0.01, adec, 1,curva), go)*harm;
	body=LFTri.ar(bodyfreq,0,bodyamp);
	body=body.tanh;
	Out.ar(out, body);
}).writeDefFile(d);
)

(//kickdrum
SynthDef(\kickdrumbmono, {
	arg out=0;
	var body, bodyfreq, bodyamp;
	var go=\trigger.kr(0!1);
	var p=\pitch.kr(36!1).midicps;
	var curvp=\pitchcurve.kr(-4!1);
	var curva=\ampcurve.kr(-4!1);
	var pdec=\pitchdecay.kr(4!1);
	var adec=\ampdecay.kr(4!1);
	var tune=\hitune.kr(300!1);
	var harm=\harmonics.kr(40!1);

	bodyfreq=(EnvGen.ar(Env.perc(0.01, pdec, 1,curvp), go)*tune)+p;
	bodyamp=EnvGen.ar(Env.perc(0.01, adec, 1,curva), go)*harm;
	body=LFTri.ar(bodyfreq,0,bodyamp);
	body=body.tanh;
	Out.ar(out, body);
}).writeDefFile(d);
)