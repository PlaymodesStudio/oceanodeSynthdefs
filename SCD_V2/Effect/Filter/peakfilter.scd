(
~synthCreator.value("PeakFilter", {|n|
	var out_level, pitch, rq, db, sig, dry, mix, wet;

	// Parameters
	out_level = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 0.05, true).lincurve(0, 1, 0, 1, 4);
	pitch = OceanodeParameterLag.ar(\pitch, 60, n, 20, 135, "vf",  0.05, true);
	rq = OceanodeParameterLag.kr(\rq, 1, n, 0.01, 1, "vf", 0.05, true);
	db = OceanodeParameterLag.kr(\db, 0, n, -1, 1, "vf",  0.05, true) * 60;  // Scale -1 to 1 to -60 to 60 dB
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf",  0.05, true);

	// Input stage
	sig = In.ar(OceanodeInput.kr(\in), n);
	dry = sig;

	// Apply peak EQ filter
	wet = BPeakEQ.ar(sig, pitch.midicps, rq, db);

	// Apply level control
	wet = wet * out_level;

	// Mix dry and wet signals
	sig = XFade2.ar(dry, wet, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Parametric EQ filter with frequency Q and gain controls", category: "Effect/Filter");
)