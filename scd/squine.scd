(
SynthDef.new(\squine13, {
	arg out;
	var p,vib,trem,finalP,x,finalSig,fm,fmp,fma;
	p=\pitch.kr(36!13, 1/30, fixedLag: true);
	vib=SinOsc.ar(\vibf.kr(0!13, 1/30, fixedLag: true),0,\viba.kr(0!13, fixedLag: true),0);
	trem=1-((SinOsc.ar(\tremf.kr(0!13),0,1,1)/2)*\trema.kr(0!13));
	finalP=p+vib;
	fmp=\fmpitch.kr(48!13, 1/30, fixedLag: true);
	fma=\fmamp.kr(0!13, 1/30, fixedLag: true);
	fm=SinOsc.ar(fmp.midicps,0)*fma;
	finalSig=Squine.ar(finalP.midicps+fm,\clip.kr(0!13, 1/30, fixedLag: true),\skew.kr(0!13, 1/30, fixedLag:true));
	finalSig=finalSig*(\levels.kr(0!13, 1/30, fixedLag: true))*trem;
	Out.ar(out, finalSig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;