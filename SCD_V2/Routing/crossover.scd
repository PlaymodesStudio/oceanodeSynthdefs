(
~synthCreator.value("Crossover", {|n|
	var source, crossFreq, slope, lowOut, highOut, lpf, hpf;
	var lowGain, highGain, lowPolarity, highPolarity, phaseAlign;
	var lowPhase, highPhase, lowDelayTime, highDelayTime;

	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);

	// Main crossover frequency parameter
	crossFreq = OceanodeParameterLag.ar(\crossfreq, 1000, n, 20, 20000, "vf", 1/30, true);

	// Filter slope selection
	slope = OceanodeParameterDropdown.kr(\slope, 1, n, "6dB:12dB:18dB:24dB");

	// Individual band gains with natural curve
	lowGain = OceanodeParameterLag.ar(\lowgain, 1, n, 0, 2, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	highGain = OceanodeParameterLag.ar(\highgain, 1, n, 0, 2, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Polarity inversion (0 = normal, 1 = inverted)
	lowPolarity = OceanodeParameter.kr(\polarity, 0, n, 0, 1, "vi");

	// Phase alignment in degrees (-180 to +180)
	lowPhase = OceanodeParameter.ar(\phase, 0, n, -180, 180, "vf");

	// Convert phase to delay time (phase shift via all-pass delay)
	// At 1kHz: 360° = 1ms, so 1° = 1/360 ms = 0.00278ms
	lowDelayTime = (lowPhase / 360) / 1000;

	// Implement different filter slopes
	lpf = Select.ar(slope, [
		LPF.ar(source, crossFreq),                                    // 6dB/oct
		RLPF.ar(source, crossFreq, 1),                               // 12dB/oct resonant
		LPF.ar(LPF.ar(source, crossFreq), crossFreq),               // 12dB/oct cascade
		LPF.ar(LPF.ar(LPF.ar(LPF.ar(source, crossFreq), crossFreq), crossFreq), crossFreq) // 24dB/oct cascade
	]);

	hpf = Select.ar(slope, [
		HPF.ar(source, crossFreq),                                    // 6dB/oct
		RHPF.ar(source, crossFreq, 1),                               // 12dB/oct resonant
		HPF.ar(HPF.ar(source, crossFreq), crossFreq),               // 12dB/oct cascade
		HPF.ar(HPF.ar(HPF.ar(HPF.ar(source, crossFreq), crossFreq), crossFreq), crossFreq) // 24dB/oct cascade
	]);

	// Apply phase alignment using all-pass delay
	lpf = DelayC.ar(lpf, 0.01, lowDelayTime.abs.clip(0, 0.01));

	// Apply polarity inversion
	lpf = Select.ar(lowPolarity, [lpf, lpf.neg]);

	// Apply individual band gains
	lowOut = lpf * lowGain;
	highOut = hpf * highGain;

	// Output to separate buses
	Out.ar(OceanodeOutput.kr(\lowout), lowOut);
	Out.ar(OceanodeOutput.kr(\highout), highOut);
	Out.ar(OceanodeOutput.kr(\mixhout), highOut+lowOut);

}, description: "Frequency crossover with polarity phase alignment and gain per band", category: "Effect/Filter");
)