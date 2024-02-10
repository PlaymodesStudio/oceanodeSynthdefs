(
SynthDef(\fm4Raw, {
	arg out=0;
	var p, pm1, pm2, pm3, pm4, sig, finalSig;

	// Ratios for operators - expecting arrays for 78 voices
	var r1 = \r1.kr(1!78); //ranges 0 to 32
	var r2 = \r2.kr(1.2!78);
	var r3 = \r3.kr(1.5!78);
	var r4 = \r4.kr(1.8!78);

	// FM Index - expecting an array for 78 voices
	var fm = \fm.kr(0.2!78); //ranges 0 to 1

	// Pitch for multiple voices - expecting 78 pitches
	p = \pitch.kr(36!78);

	// Modulators
	pm1 = SinOsc.ar(p.midicps * r1, 0, fm);
	pm2 = SinOsc.ar(p.midicps * r2, 0, fm);
	pm3 = SinOsc.ar(p.midicps * r3, 0, fm);
	pm4 = SinOsc.ar(p.midicps * r4, 0, fm);

	// Carrier with modulation applied from all 4 modulators
	sig = SinOsc.ar(p.midicps, pm1 + pm2 + pm3 + pm4);

	// Amplitude control
	finalSig = sig * VarLag.kr(\levels.kr(0.5!78), 1/30);

	// Output - 78 channels
	Out.ar(out, finalSig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


