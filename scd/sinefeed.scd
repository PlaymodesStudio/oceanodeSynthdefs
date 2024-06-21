


(
SynthDef(\kontour13, {
	arg out=0;
	var feedback, sig,sig2;
	var phmod1=\phfeed1.kr(0.5!13, 1/30, fixedLag: true); //0 to 3
	var modamp=\modamp.kr(1!13, 1/30, fixedLag: true); //1 to 6
	var levels=\levels.kr(1!13, 1/30, fixedLag: true);
	var pitch1=\pitch1.kr(24!13, 1/30, fixedLag: true).midicps;
	var pitch2=\pitch2.kr(60!13, 1/30, fixedLag: true).midicps;
	var phlp=\phlp.kr(130!13, 1/30, fixedLag: true).midicps;
	var shape1=\shaper1.kr(2!13, 1/30, fixedLag:true);
	var shape2=\shaper2.kr(2!13, 1/30, fixedLag:true);

	feedback = LPF.ar(LocalIn.ar(13),phlp);
	feedback=(feedback*shape1).sin;

	//modulator
	sig2=SinOsc.ar(pitch2);
	sig2=(sig2*shape2).sin;
	sig2=sig2*modamp;

	//carrier
	sig = SinOsc.ar(pitch1, (feedback * phmod1) + sig2).tanh;

	// Feedback loop
	LocalOut.ar(sig);

	// Output
	Out.ar(out, levels*sig.tanh);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


(
SynthDef(\sinefeed13, {
	arg out=0;
	var feedback, sig;
	var phmod=\phfeed.kr(2!13, 1/30, fixedLag: true); //0 to 3
	var ampmod=\amp.kr(2!13, 1/30, fixedLag: true); //1 to 6
	var levels=\levels.kr(1!13, 1/30, fixedLag: true);
	var pitch=\pitch.kr(24!13, 1/30, fixedLag: true).midicps;


	feedback = LocalIn.ar(13);

	// SinOsc with feedback in the phase
	sig = SinOsc.ar(pitch, feedback * phmod, ampmod).tanh;

	// Apply Allpass filters
	9.do {
		sig = AllpassL.ar(sig, 0.3, { 0.2.rand + 0.1 } ! 13, 5);
	};

	// Feedback loop
	LocalOut.ar(sig);

	// Output
	Out.ar(out, levels*sig.tanh);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\sawfeed13, {
	arg out=0;
	var feedback, sig;
	var phmod=\phfeed.kr(0.15!13, 1/30, fixedLag: true); //0 to 3
	var ampmod=\amp.kr(1!13, 1/30, fixedLag: true); //1 to 6
	var levels=\levels.kr(1!13, 1/30, fixedLag: true);
	var pitch=\pitch.kr(36!13, 1/30, fixedLag: true).midicps;


	feedback = LocalIn.ar(13);

	//feedback in the phase
	sig = SawOS.ar(pitch, feedback * phmod, 0, ampmod).tanh;
	//sig = SquareOS.ar(pitch, feedback * phmod, 0.25, ampmod).tanh;

	// Apply Allpass filters
	9.do {
		sig = AllpassL.ar(sig, 0.3, { 0.2.rand + 0.1 } ! 13, 5);
	};

	// Feedback loop
	LocalOut.ar(sig);

	// Output
	Out.ar(out, levels*sig.tanh);
}).writeDefFile(d);
)

(
SynthDef(\pulsefeed13, {
	arg out=0;
	var feedback, sig;
	var phmod=\phfeed.kr(0.15!13, 1/30, fixedLag: true); //0 to 3
	var ampmod=\amp.kr(1!13, 1/30, fixedLag: true); //1 to 6
	var levels=\levels.kr(1!13, 1/30, fixedLag: true);
	var pitch=\pitch.kr(36!13, 1/30, fixedLag: true).midicps;
	var pw=\pw.kr(0.5!13, 1/30, fixedLag: true);


	feedback = LocalIn.ar(13);

	//feedback in the phase
	sig = SquareOS.ar(pitch, feedback * phmod, pw, 0, ampmod).tanh;
	//sig = SquareOS.ar(pitch, feedback * phmod, 0.25, ampmod).tanh;

	// Apply Allpass filters
	9.do {
		sig = AllpassL.ar(sig, 0.3, { 0.2.rand + 0.1 } ! 13, 5);
	};

	// Feedback loop
	LocalOut.ar(sig);

	// Output
	Out.ar(out, levels*sig.tanh);
}).writeDefFile(d);
)


