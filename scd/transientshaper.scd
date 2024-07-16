(
SynthDef(\transientshaper13, {
	arg out = 0, in=0;
	var divideFreq = \dividefreq.kr(500!13), transientVol = \transientvol.kr(1!13), sustainVol = \sustainvol.kr(1!13);
	var inSig, slewSig, sustainSig, transientSig, mixSig;

	inSig = In.ar(in, 13);

	// use slew to remove transients and higher freqs
	slewSig = Slew.ar(inSig, divideFreq, divideFreq);
	sustainSig = slewSig * sustainVol;

	transientSig = (inSig - slewSig) * transientVol;

	mixSig = sustainSig + transientSig;
	Out.ar(out, mixSig) * 0.5;

}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
