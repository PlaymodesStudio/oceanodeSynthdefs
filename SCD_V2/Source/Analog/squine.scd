(
~synthCreator.value("Squine", {|n|
	var p, pulsew, finalSig, vib, trem, tremRate, tremAmount, vibRate, vibAmount,
	    finalP, clip, skew, syncfreq, syncEnabled;

	// Main pitch control with lag for smooth transitions
	p = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true);

	// Tremolo and vibrato parameters
	tremRate = OceanodeParameterLag.kr(\tremf, 0, n, 0, 8, "vf", 1/30, true);
	tremAmount = OceanodeParameterLag.kr(\trema, 0, n, 0, 1, "vf", 1/30, true);
	vibRate = OceanodeParameterLag.kr(\vibf, 0, n, 0, 8, "vf", 1/30, true);
	vibAmount = OceanodeParameterLag.kr(\viba, 0, n, 0, 1, "vf", 1/30, true);

	// Squine specific parameters
	clip = OceanodeParameterLag.ar(\clip, 0, n, 0, 1, "vf", 1/30, true);
	skew = OceanodeParameterLag.ar(\skew, 0, n, 0, 1, "vf", 1/30, true);

	// Hard sync parameters
	syncfreq = OceanodeParameterLag.ar(\syncfreq, 100, n, 10, 5000, "vf", 1/30, true);
	syncEnabled = OceanodeParameterDropdown.kr(\sync, 0, n, "Off:On");

	// Apply vibrato to pitch
	vib = SinOsc.ar(vibRate, 0, vibAmount, 0);
	finalP = p + vib;

	// Create either standard Squine or hardsynced Squine based on sync selection
	finalSig = Select.ar(syncEnabled, [
		// Regular Squine (no hardsync)
		Squine.ar(finalP.midicps, clip, skew),

		// Hardsynced Squine
		Squine.ar(syncfreq, clip, skew, Impulse.ar(finalP.midicps))
	]);

	// Apply tremolo to amplitude
	trem = 1 - ((SinOsc.ar(tremRate, 0, 1, 1) / 2) * tremAmount);

	// Apply level control with proper dB scaling
	finalSig = finalSig * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4) * trem;

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "Squine oscillator with optional hardsync", category: "Source/Analog");
)