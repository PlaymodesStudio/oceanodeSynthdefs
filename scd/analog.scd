(
SynthDef.new(\analog, {
	arg out;
	var p,vib,trem,finalP,x,waves,pulsew,finalSig,fm,fmp,fma;
	p=\pitch.kr(36!78);
	pulsew=\pw.kr(0!78);
	vib=SinOsc.ar(\vibf.kr(0!78),0,\viba.kr(0!78),0);
	trem=1-((SinOsc.ar(\tremf.kr(0!78),0,1,1)/2)*\trema.kr(0!78));
	finalP=p+vib;
	fmp=\fmpitch.kr(48!78);
	fma=\fmamp.kr(0!78);
	fm=SinOsc.ar(fmp.midicps,0)*fma;

	waves=[
		Saw.ar(finalP.midicps+fm,1,0),
		LFTri.ar(finalP.midicps+fm,0),
		Pulse.ar(finalP.midicps+fm,(pulsew+0.5)%1,1),
		SinOsc.ar(finalP.midicps+fm,0)
	];

	finalSig=Select.ar(\type.kr(0!78),waves);
	finalSig=finalSig*(\levels.kr(0!78, 1/30, fixedLag:true))*trem;
	Out.ar(out, finalSig);
}).writeDefFile(d);
)

(
SynthDef.new(\analog13, {
	arg out;
	var p,vib,trem,finalP,x,waves,pulsew,finalSig,fm,fmp,fma;
	p=\pitch.kr(36!13);
	pulsew=\pw.kr(0!13);
	vib=SinOsc.ar(\vibf.kr(0!13),0,\viba.kr(0!13),0);
	trem=1-((SinOsc.ar(\tremf.kr(0!13),0,1,1)/2)*\trema.kr(0!13));
	finalP=p+vib;
	fmp=\fmpitch.kr(48!13);
	fma=\fmamp.kr(0!13);
	fm=SinOsc.ar(fmp.midicps,0)*fma;

	waves=[
		Saw.ar(finalP.midicps+fm,1,0),
		LFTri.ar(finalP.midicps+fm,0),
		Pulse.ar(finalP.midicps+fm,(pulsew+0.5)%1,1),
		SinOsc.ar(finalP.midicps+fm,0)
	];

	finalSig=Select.ar(\type.kr(0!13),waves);
	finalSig=finalSig*(\levels.kr(0!13, 1/30, fixedLag:true))*trem;
	Out.ar(out, finalSig);
}).writeDefFile(d);
)

(
SynthDef.new(\analogmono, {
	arg out;
	var p,vib,trem,finalP,x,waves,pulsew,finalSig,fm,fmp,fma;
	p=\pitch.kr(36!1);
	pulsew=\pw.kr(0!1);
	vib=SinOsc.ar(\vibf.kr(0!1),0,\viba.kr(0!1),0);
	trem=1-((SinOsc.ar(\tremf.kr(0!1),0,1,1)/2)*\trema.kr(0!1));
	finalP=p+vib;
	fmp=\fmpitch.kr(48!1);
	fma=\fmamp.kr(0!1);
	fm=SinOsc.ar(fmp.midicps,0)*fma;

	waves=[
		Saw.ar(finalP.midicps+fm,1,0),
		LFTri.ar(finalP.midicps+fm,0),
		Pulse.ar(finalP.midicps+fm,(pulsew+0.5)%1,1),
		SinOsc.ar(finalP.midicps+fm,0)
	];

	finalSig=Select.ar(\type.kr(0!1),waves);
	finalSig=finalSig*(\levels.kr(0!1, 1/30, fixedLag:true))*trem;
	Out.ar(out, finalSig);
}).writeDefFile(d);
)

(
SynthDef.new(\analog13ar, {
	arg out=0,in=0;
	var p,vib,trem,finalP,x,waves,pulsew,finalSig,fm,fmp,fma,input;
	p=\pitch.kr(36!13);
	pulsew=\pw.kr(0!13);
	vib=SinOsc.ar(\vibf.kr(0!13),0,\viba.kr(0!13),0);
	trem=1-((SinOsc.ar(\tremf.kr(0!13),0,1,1)/2)*\trema.kr(0!13));
	finalP=p+vib;
	fmp=\fmpitch.kr(48!13);
	fma=\fmamp.kr(0!13);
	fm=SinOsc.ar(fmp.midicps,0)*fma;
	input = In.ar(in, 13);

	waves=[
		Saw.ar(finalP.midicps+fm,1,0),
		LFTri.ar(finalP.midicps+fm,0),
		Pulse.ar(finalP.midicps+fm,(pulsew+0.5)%1,1),
		SinOsc.ar(finalP.midicps+fm,0)
	];

	finalSig=Select.ar(\type.kr(0!13),waves);
	finalSig=finalSig*input*trem;
	Out.ar(out, finalSig);
}).writeDefFile(d);
)
d = thisProcess.nowExecutingPath.dirname;
