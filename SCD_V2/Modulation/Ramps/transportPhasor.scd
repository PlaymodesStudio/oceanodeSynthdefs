~synthCreator.value("transportPhasor", {|n|
	var beatTransport, reset, jumpTrig, manualReset, anyTrig;
	var beats, bpm, fm, forwardPLL, resyncTime, pllEnable;
	var phoff;
	var cycleDur, basePhaseInc, baseRate, modulatedRate;
	var phasor01, phase01, correctPhase, sig;
	var idealPhase, feedbackPhase, error, correction;
	var pllWeight, fmDeviation;
	var jumpGate, pllActive;

	// --- transport ---
	beatTransport = OceanodeParameterLag.kr(\beattransport, 0, n, 0, 1e12, "vf", 0);

	// External jump trigger
	jumpTrig = OceanodeParameter.ar(\jump, 0, n, 0, 1, "vi");
	jumpTrig = Trig1.kr(A2K.kr(jumpTrig.asArray.sum), SampleDur.ir);

	// Manual reset
	reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");
	manualReset = Trig1.kr(A2K.kr(reset.asArray.sum), SampleDur.ir);

	// musical params
	beats = OceanodeParameterLag.kr(\beats, 1, n, 0.001, 128, "vf", 1/30, true);
	bpm   = OceanodeParameterLag.kr(\bpm, 120, n, 1, 999, "vf", 1/30, true);
	fm    = OceanodeParameterLag.ar(\fm, 1, n, 0, 10, "vf", 1/30, true);

	// PLL params
	pllEnable  = OceanodeParameter.kr(\pll_enable, 0, 1, 0, 1, "i");  // Master enable (default OFF)
	resyncTime = OceanodeParameterLag.kr(\resynctime, 0.5, 1, 0.01, 10, "f", 1/30, true);
	forwardPLL = OceanodeParameter.kr(\fwd_pll, 1, 1, 0, 1, "i");

	// Combined trigger - extended
	anyTrig = Trig.kr(manualReset + jumpTrig, ControlDur.ir * 3);

	// Calculate correct phase from beatTransport (tempo-locked target)
	correctPhase = (beatTransport / beats).frac;

	// Base phase increment (unmodulated tempo rate)
	cycleDur = beats * (60 / bpm);
	basePhaseInc = 1 / (cycleDur * SampleRate.ir);

	// Base rate with FM applied
	baseRate = basePhaseInc * fm;

	// --- PLL Logic (always compute, but only use if enabled) ---

	// Create a gate that stays HIGH during jump and for a period after
	jumpGate = Trig.kr(anyTrig, resyncTime * 2);

	// Get feedback from our own output phase
	feedbackPhase = LocalIn.ar(n);

	// Ideal phase is the tempo-locked phase
	idealPhase = correctPhase;

	// Calculate error
	error = Select.kr(jumpGate, [
		(idealPhase - A2K.kr(feedbackPhase)).wrap(-0.5, 0.5),
		0
	]);

	// PLL weight
	fmDeviation = A2K.kr((fm - 1).abs);
	pllWeight = exp(fmDeviation.neg * 5);

	// Disable PLL during jumps AND if master switch is off
	pllActive = pllWeight * (1 - jumpGate) * pllEnable;

	// Calculate correction rate
	correction = (error * pllActive) / (resyncTime.max(0.01) * SampleRate.ir);

	// Total rate = base rate + PLL correction (correction is 0 when pllEnable=0)
	modulatedRate = baseRate + K2A.ar(correction);

	// Optional: forward-only constraint
	modulatedRate = Select.ar(K2A.ar(forwardPLL), [
		modulatedRate,
		modulatedRate.max(0)
	]);

	// --- Phasor ---

	phasor01 = Phasor.ar(
		trig: K2A.ar(anyTrig),
		rate: modulatedRate,
		start: 0,
		end: 1,
		resetPos: K2A.ar(correctPhase)
	);

	// Feed back phase for PLL
	// When pllEnable=0, this doesn't matter since correction will be 0
	LocalOut.ar(Select.ar(K2A.ar(jumpGate), [
		phasor01,
		K2A.ar(correctPhase)
	]));

	// range / offset
	phoff = OceanodeParameterLag.ar(\phoff, 0, n, -1, 1, "vf", 1/30, true);

	phase01 = (phasor01 + phoff).wrap(0, 1);
	sig = phase01;

	Out.ar(OceanodeOutput.kr(\out), sig);
},
description: "BeatTransport-synced phasor with FM and PLL",
category: "Modulation/Ramps");