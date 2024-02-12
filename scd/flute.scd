(
SynthDef.new(\flute, { arg scl = 0.2, ipress = 0.9, out=0;
	var numchan = 13;
	var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
	var poly, signalOut, ifqc;
	var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;
	var fdbckArray;
	var vibF = VarLag.kr(\vibf.kr(5!numchan), 1/30);
	var ibreath = VarLag.kr(\breath.kr(0.1!numchan), 1/30);
	var ifeedbk1 = VarLag.kr(\feed1.kr(0.3!numchan), 1/30); //max 0.7
	var ifeedbk2 = VarLag.kr(\feed2.kr(0.5!numchan), 1/30); //max 0.7
	var freq=VarLag.kr(\pitch.kr(60!numchan).midicps, 1/30);

	sr = SampleRate.ir;
	cr = ControlRate.ir;
	block = cr.reciprocal;

	ifqc = freq;

	// noise envelope
	kenv1 = VarLag.kr(\noise.kr(1!numchan), 1/30);
	// overall envelope
	kenv2 = kenv1; // Placeholder for any intended overall envelope processing
	// vibrato envelope
	kenvibr = VarLag.kr(\viba.kr(0.4!numchan), 1/30);

	// create air flow and vibrato
	aflow1 = LFClipNoise.ar(sr * kenv1); // Adjusted for multichannel
	kvibr = SinOsc.ar(vibF, 0, 0.1 * kenvibr);

	asum1 = (ibreath * aflow1) + kenv1 + kvibr;
	afqc = ifqc.reciprocal - (asum1 / 20000) - (9 / sr) + (ifqc / 12000000) - block;

	fdbckArray = LocalIn.ar(numchan);

	aflute1 = fdbckArray;
	asum2 = asum1 + (aflute1 * ifeedbk1);

	ax = DelayC.ar(asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - (asum1 / ifqc / cr) + 0.001);

	apoly = ax - (ax.cubed);
	asum3 = apoly + (aflute1 * ifeedbk2);
	avalue = LPF.ar(asum3, 2000);

	aflute1 = DelayC.ar(avalue, ifqc.reciprocal - block, afqc);

	fdbckArray = aflute1;

	LocalOut.ar(fdbckArray);

	signalOut = avalue * VarLag.kr(\levels.kr(0.1!numchan), 1/30);

	// This part ensures multichannel expansion to the specified number of channels
	// If 'out' is expected to be the starting channel for a multichannel output
	signalOut = Mix.fill(numchan, { signalOut });

	OffsetOut.ar(out, signalOut);
}).writeDefFile(d); // Use .add to add it to the server's SynthDef list
)

d = thisProcess.nowExecutingPath.dirname;
