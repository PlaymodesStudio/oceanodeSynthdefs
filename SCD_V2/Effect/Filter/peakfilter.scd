(
~synthCreator.value("PeakFilter", {|n|
	var out_level, pitch, rq, db, sig, dry, mix, wet;

	// Parameters
	out_level = OceanodeParameter.ar(\levels, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	pitch = OceanodeParameter.ar(\pitch, 60, n, 20, 135, "vf");
	rq = OceanodeParameter.ar(\rq, 1, n, 0.01, 1, "vf");
	db = OceanodeParameter.ar(\db, 0, n, -1, 1, "vf") * 60;  // Scale -1 to 1 to -60 to 60 dB
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

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