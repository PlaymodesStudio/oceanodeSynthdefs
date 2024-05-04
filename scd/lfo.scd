(
SynthDef.new(\lfo13, {
	arg out;
	var p,waves,pulsew,finalSig,poww;
	p=\hz.kr(1!13, 1/30, fixedLag:true);
	pulsew=\pw.kr(0!13, 1/30, fixedLag:true);
	poww=\exp.kr(1!13, 1/30, fixedLag:true);
	waves=[
		LFSaw.ar(p),
		SinOsc.ar(p),
		LFTri.ar(p),
		LFPulse.ar(p,(pulsew+0.5)%1),
		LFDNoise3.ar(p);
	];

	finalSig=SelectX.ar(\shape.kr(0!13, 1/30, fixedLag:true),waves);
	finalSig=(finalSig+1)/2;
	finalSig=finalSig.pow(poww);
	finalSig=1-(finalSig*(\levels.kr(0!13, 1/30, fixedLag:true)));
	Out.ar(out, finalSig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
