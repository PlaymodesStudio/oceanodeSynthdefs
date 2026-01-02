(
~synthCreator.value("Flute", {|n|
	var pch, ibreath, ifeedbk1, ifeedbk2, vibamp, vibfreq, lpf, noise, levels;
	var kenv1, kenvibr, kvibr, sr, cr, block, poly, signalOut, ifqc, fdbckArray;
	var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;

	// Main parameters with lag for smooth transitions
	pch = OceanodeParameterLag.ar(\pitch, 32, n, 0, 128, "vf", 1/30, true);
	ibreath = OceanodeParameterLag.kr(\ibreath, 0.09, n, 0, 1, "vf", 1/30, true);
	ifeedbk1 = OceanodeParameterLag.kr(\ifeedbk1, 0.4, n, 0, 1, "vf", 1/30, true);
	ifeedbk2 = OceanodeParameterLag.kr(\ifeedbk2, 0.4, n, 0, 1, "vf", 1/30, true);
	vibamp = OceanodeParameterLag.kr(\vibamp, 0.2, n, 0, 1, "vf", 1/30, true);
	vibfreq = OceanodeParameterLag.kr(\vibfreq, 5, n, 0, 10, "vf", 1/30, true);
	lpf = OceanodeParameterLag.kr(\lpf, 2000, n, 0, 10000, "vf", 1/30, true);
	noise = OceanodeParameterLag.kr(\noise, 1, n, 0, 1, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);

	// Physical modeling implementation
	sr = SampleRate.ir;
	cr = ControlRate.ir;
	block = cr.reciprocal;
	ifqc = pch.midicps;

	// Create air flow and vibrato
	aflow1 = LFClipNoise.ar(sr!n, noise);
	kvibr = SinOsc.ar(vibfreq, 0, 0.1 * vibamp);
	asum1 = (ibreath * aflow1) + noise + kvibr;
	afqc = ifqc.reciprocal - (asum1/20000) - (9/sr) + (ifqc/12000000) - block;
	fdbckArray = LocalIn.ar(n);
	aflute1 = fdbckArray;
	asum2 = asum1 + (aflute1 * ifeedbk1);
	ax = DelayC.ar(asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - (asum1/ifqc/cr) + 0.001);
	apoly = ax - (ax.cubed);
	asum3 = apoly + (aflute1 * ifeedbk2);
	avalue = Sanitize.ar(LPF.ar(asum3, lpf));
	aflute1 = DelayC.ar(avalue, ifqc.reciprocal - block, afqc);
	LocalOut.ar(Sanitize.ar(aflute1));

	// Finalize signal
	signalOut = LeakDC.ar(avalue);
	signalOut = Limiter.ar(signalOut);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), signalOut * levels);

}, description: "Physical modeling flute synthesizer", category: "Source/PhysicalModelling");
)