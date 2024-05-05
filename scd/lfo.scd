(
SynthDef.new(\lfo13, {
	arg out;
	var p,waves,pulsew,finalSig,poww;
	p=\hz.kr(1!13, 1/30, fixedLag:true);
	pulsew=\pw.kr(0!13, 1/30, fixedLag:true);
	poww=\pow.kr(1!13, 1/30, fixedLag:true);
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


(
SynthDef.new(\lfo13, {
	arg out;
	var p, ph, waves, pulsew, finalSig, poww, bipow;
	var k1, k2, k3;

	ph=\phoff.kr(0!13, 1/30, fixedLag: true);
	p = \hz.kr(1!13, 1/30, fixedLag: true);
	pulsew = \pw.kr(0!13, 1/30, fixedLag: true);
	poww = \pow.kr(1!13, 1/30, fixedLag: true);
	bipow = \bipow.kr(0!13, 1/30, fixedLag: true);

	waves = [
		(((((LFSaw.ar(p)+1)/2)+ph)%1)*2)-1,
		SinOsc.ar(p, ph),
		LFTri.ar(p, ph),
		LFPulse.ar(p, ph, (pulsew + 0.5) % 1),
		LFDNoise3.ar(p)
	];

	finalSig = SelectX.ar(\shape.kr(0!13, 1/30, fixedLag: true), waves);
	finalSig = (finalSig + 1) / 2; // Normalizing the signal range [0, 1]
	finalSig = finalSig.pow(poww);
	// Implementing the bipow transformation as specified
	finalSig = (finalSig * 2) - 1; // Convert to bipolar range [-1, 1]
	k1 = 2 * bipow * 0.99999;
	k2 = k1 / ((bipow * -1 * 0.999999) + 1);
	k3 = k2 * abs(finalSig) + 1;
	finalSig = finalSig * (k2 + 1) / k3; // Apply the non-linear transformation
	finalSig = (finalSig + 1) * 0.5; // Convert back to unipolar range [0, 1]
	finalSig = 1 - (finalSig * \levels.kr(0!13, 1/30, fixedLag: true)); // Scaling with levels control
	Out.ar(out, finalSig);
}).writeDefFile(d);
)
