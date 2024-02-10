(
SynthDef(\fmcomplex13, {
	arg out=0;
	var p, pm1, pm2, pm3, pm4, sig, finalSig;

	// Ratios for operators - expecting arrays for 13 voices
	var r1 = \r1.kr(1!13); //ranges 0 to 32
	var r2 = \r2.kr(2!13);
	var r3 = \r3.kr(3!13);
	var r4 = \r4.kr(4!13);

	// FM Index - expecting an array for 13 voices with feedback amounts
	var fm1 = VarLag.kr(\fm1.kr(0.2!13), 1/30);
	var fm2 = VarLag.kr(\fm2.kr(0.2!13), 1/30);
	var fm3 = VarLag.kr(\fm3.kr(0.2!13), 1/30);
	var fm4 = VarLag.kr(\fm4.kr(0.2!13), 1/30);

	var feed1 = VarLag.kr(\feed1.kr(0!13), 1/30);
	var feed2 = VarLag.kr(\feed2.kr(0!13), 1/30);
	var feed3 = VarLag.kr(\feed3.kr(0!13), 1/30);
	var feed4 = VarLag.kr(\feed4.kr(0!13), 1/30);

	// Pitch for multiple voices - expecting 13 pitches
	p = \pitch.kr(36!13);

	// Modulators with feedback
	pm1 = SinOscFB.ar(p.midicps * r1, feed1, fm1);
	pm2 = SinOscFB.ar(p.midicps * r2, feed2, fm2);
	pm3 = SinOscFB.ar(p.midicps * r3, feed3, fm3);
	pm4 = SinOscFB.ar(p.midicps * r4, feed4, fm4);

	// Carrier with modulation applied from all 4 modulators
	sig = SinOsc.ar(p.midicps, pm1 + pm2 + pm3 + pm4);

	// Amplitude control
	finalSig = sig * VarLag.kr(\levels.kr(0.5!13), 1/30);

	// Output - 13 channels
	Out.ar(out, finalSig);
}).play;
)

d = thisProcess.nowExecutingPath.dirname;
