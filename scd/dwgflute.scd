(
SynthDef(\dwgclarinet13, {
	arg out=0;
	var nch=13;
	var freq=\pitch.kr(60!nch).midicps,
	contour=\contour.kr(1!nch),
	amp=\amp.kr(0.5!nch),
	pc= \closepressure.kr(1!nch),
	m= \slopeopening.kr(1.2!nch),
	c1= \inversedecay.kr(0.2!nch),
	c3= \hiloss.kr(7!nch),
	viba=\viba.kr(0.001!13),
	vibf=\vibf.kr(4!13);
    var env,vib,son;
    amp = LinLin.kr(amp,0,1,0.76,1);
	env = DC.ar(contour)*amp;
    vib = SinOsc.kr(vibf,0,viba,1);
    son = DWGClarinet3.ar(Lag.kr(freq,0)*vib, env,pc,m, 1,1000,c1,c3);
    son = HPF.ar(son,200);
    Out.ar(out, son);
}).play;
)

(
SynthDef(\dwgflute13, {
	arg out=0;
	var freq=\pitch.kr(64!13).midicps,
	amp=\amp.kr(0.5!13),
	endr= \endreflection.kr(0.45!13),
	jetr= \jetreflection.kr(0.24!13),
	jetRa=\jetdelayratio.kr(0.33!13),
	noisegain=\noisegain.kr(120!13),
	lpf=\lpf.kr(5000!13),
	hpf=\hpf.kr(200!13),
	viba=\viba.kr(0.03!13),
	vibf=\vibf.kr(4!13),
	contour=\contour.kr(1!13),
	levels=\levels.kr(0.25!13);

    var vib,env,signal;
    vib = SinOsc.kr(vibf,0,viba,1);
	env = contour*(1.1 + (amp*0.2)) *(vib+(0.001*noisegain*WhiteNoise.ar()));
    signal = DWGFlute.ar(freq, env,endr,jetr,jetRa, 1,1000);
    signal = HPF.ar(LPF.ar(signal,lpf),hpf);
    Out.ar(out,signal*levels*amp);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

