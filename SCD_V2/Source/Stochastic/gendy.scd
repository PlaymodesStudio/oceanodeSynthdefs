// GENDY1-based synthesizer for Oceanode
(
~synthCreator.value("Gendy", {|n|
	var p, finalSig, freq, ampDist, durDist, adParam, ddParam, minFreq, maxFreq, ampScale, durScale;
	var numPoints, initCPs, kNum, vib, trem, tremRate, tremAmount, vibRate, vibAmount;
	var filterType, filterFreq, filterRes, useFixedFreq;

	// Main pitch control with lag for smooth transitions
	p = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true);

	// GENDY1 specific parameters
	ampDist = OceanodeParameterDropdown.kr(\ampdist, 1, n, "step:linear:cauchy:logist:hyperbcos:arcsine:expon:sinus");
	durDist = OceanodeParameterDropdown.kr(\durdist, 1, n, "step:linear:cauchy:logist:hyperbcos:arcsine:expon:sinus");

	// Control parameters for distributions
	adParam = OceanodeParameterLag.ar(\adparam, 1, n, 0.0001, 1, "vf", 1/30, true);
	ddParam = OceanodeParameterLag.ar(\ddparam, 1, n, 0.0001, 1, "vf", 1/30, true);

	// Scaling factors - with much wider ranges to match examples
	ampScale = OceanodeParameterLag.ar(\ampscale, 0.3, n, 0.0001, 1, "vf", 1/30, true);
	durScale = OceanodeParameterLag.ar(\durscale, 0.05, n, 0.0001, 1, "vf", 1/30, true);

	// Control points - now with presets based on examples
	numPoints = OceanodeParameterDropdown.kr(\points, 0, n, "2:5:7:10:12:20:40");
	initCPs = OceanodeParameterDropdown.kr(\initcps, 0, n, "rand:sinus");

	// Frequency range control - direct, not relative to MIDI note
	minFreq = OceanodeParameterLag.ar(\minfreq, 30, n, 1, 1000, "vf", 1/30, true);
	maxFreq = OceanodeParameterLag.ar(\maxfreq, 100, n, 1, 2000, "vf", 1/30, true);

	// Frequency mode selection
	useFixedFreq = OceanodeParameterDropdown.kr(\freqmode, 0, n, "midi-based:fixed-range");

	// Tremolo and vibrato parameters
	tremRate = OceanodeParameterLag.ar(\tremf, 0, n, 0, 8, "vf", 1/30, true);
	tremAmount = OceanodeParameterLag.ar(\trema, 0, n, 0, 1, "vf", 1/30, true);
	vibRate = OceanodeParameterLag.ar(\vibf, 0, n, 0, 8, "vf", 1/30, true);
	vibAmount = OceanodeParameterLag.ar(\viba, 0, n, 0, 1, "vf", 1/30, true);

	// Apply vibrato to pitch
	vib = SinOsc.ar(vibRate, 0, vibAmount, 0);
	p = (p + vib);

	// Frequency range selection based on mode
	minFreq = Select.kr(useFixedFreq, [(p - 24).midicps, minFreq]);
	maxFreq = Select.kr(useFixedFreq, [(p + 24).midicps, maxFreq]);

	// Frequency fluctuation amount (kNum)
	kNum = OceanodeParameterLag.ar(\freqfluct, 0.5, n, 0, 1, "vf", 1/30, true);

	// Create the GENDY1 oscillator with point count conversion from dropdown
	finalSig = Gendy1.ar(
		ampDist,
		durDist,
		adParam,
		ddParam,
		minFreq,
		maxFreq,
		ampScale,
		durScale,
		(numPoints+2).asInteger, // Add 2 because dropdown indices start at 0
		initCPs,
		kNum
	);

	// Filter processing section, like in the example
	filterType = OceanodeParameterDropdown.kr(\filtertype, 0, n, "none:lpf:bpf:comb");
	filterFreq = OceanodeParameterLag.ar(\filterfreq, 500, n, 20, 5000, "vf", 1/30, true);
	filterRes = OceanodeParameterLag.ar(\filterres, 0.3, n, 0.01, 1.0, "vf", 1/30, true);

	// Apply filter based on selection
	finalSig = Select.ar(filterType, [
		finalSig, // None
		RLPF.ar(finalSig, filterFreq, filterRes), // LPF
		Resonz.ar(finalSig, filterFreq, filterRes), // BPF
		CombN.ar(finalSig, 0.1, 0.1, 5 * filterRes, filterRes) // Comb
	]);

	// Apply tremolo to amplitude
	trem = 1 - ((SinOsc.ar(tremRate, 0, 1, 1) / 2) * tremAmount);

	// Apply level control with proper dB scaling
	finalSig = finalSig * OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4) * trem;

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalSig);
}, description: "GENDY1 stochastic synthesizer with dynamic waveform generation", category: "Source/Stochastic");
)

simplex