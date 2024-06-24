d = thisProcess.nowExecutingPath.dirname;

(
SynthDef.new(\blit13, {
	arg out;
	var p,vib,trem,finalP,x,waves,finalSig,fm,fmp,fma,leak;
	p=\pitch.kr(36!13);
	leak=\leak.kr(0.99!13);
	vib=SinOsc.ar(\vibf.kr(0!13),0,\viba.kr(0!13),0);
	trem=1-((SinOsc.ar(\tremf.kr(0!13),0,1,1)/2)*\trema.kr(0!13));
	finalP=p+vib;
	fmp=\fmpitch.kr(48!13);
	fma=\fmamp.kr(0!13);
	fm=SinOsc.ar(fmp.midicps,0)*fma;

	waves=[
		BlitB3.ar(finalP.midicps+fm),
		BlitB3Saw.ar(finalP.midicps+fm),
		BlitB3Square.ar(finalP.midicps+fm),
		BlitB3Tri.ar(finalP.midicps+fm)
	];

	finalSig=Select.ar(\type.kr(0!13),waves);
	finalSig=finalSig*(\levels.kr(0!13, 1/30, fixedLag:true))*trem;
	Out.ar(out, finalSig);
}).writeDefFile(d);
)