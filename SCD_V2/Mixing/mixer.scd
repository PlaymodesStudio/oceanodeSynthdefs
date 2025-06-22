(
~synthCreator.value("Mixer", {|n|
	var sig1, sig2, finalSig;

	// Get input signals and apply level controls
	sig1 = In.ar(OceanodeInput.kr(\in), n) * OceanodeParameterLag.ar(\levels1, 0.5, n, 0, 1, "vf", 1/30, true);
	sig2 = In.ar(OceanodeInput.kr(\in2), n) * OceanodeParameterLag.ar(\levels2, 0.5, n, 0, 1, "vf", 1/30, true);

	// Mix the signals
	finalSig = sig1 + sig2;

	// Apply master level with proper curve for natural level control
	finalSig = finalSig * OceanodeParameterLag.ar(\masterlevel, 1, n, 0, 1, "vf", 1/30, true);

	// Output
	Out.ar(OceanodeOutput.kr(\out), finalSig);
}, description: "Two input mixer with per channel level controls and master level", category: "Mixing");
)