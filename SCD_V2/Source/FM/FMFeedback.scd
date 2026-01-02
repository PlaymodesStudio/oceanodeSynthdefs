(
~synthCreator.value("FMFeedback", {|n|
	var pm1, pm2, pm3, pm4, sig, finalSig;

	// Pitch parameter with lag for smooth changes
	var p = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true);

	// Ratio parameters for the four operators
	var r1 = OceanodeParameterLag.kr(\r1, 1, n, 0, 32, "vi", 1/30, true);
	var r2 = OceanodeParameterLag.kr(\r2, 2, n, 0, 32, "vi", 1/30, true);
	var r3 = OceanodeParameterLag.kr(\r3, 3, n, 0, 32, "vi", 1/30, true);
	var r4 = OceanodeParameterLag.kr(\r4, 4, n, 0, 32, "vi", 1/30, true);

	// FM Index parameters with lag
	var fm1 = OceanodeParameterLag.ar(\fm1, 0.2, n, 0, 10, "vf", 1/30, true);
	var fm2 = OceanodeParameterLag.ar(\fm2, 0.2, n, 0, 10, "vf", 1/30, true);
	var fm3 = OceanodeParameterLag.ar(\fm3, 0.2, n, 0, 10, "vf", 1/30, true);
	var fm4 = OceanodeParameterLag.ar(\fm4, 0.2, n, 0, 10, "vf", 1/30, true);

	// Feedback amount parameters with lag
	var feed1 = OceanodeParameterLag.kr(\feed1, 0, n, 0, 1, "vf", 1/30, true);
	var feed2 = OceanodeParameterLag.kr(\feed2, 0, n, 0, 1, "vf", 1/30, true);
	var feed3 = OceanodeParameterLag.kr(\feed3, 0, n, 0, 1, "vf", 1/30, true);
	var feed4 = OceanodeParameterLag.kr(\feed4, 0, n, 0, 1, "vf", 1/30, true);

	// Modulators with feedback
	pm1 = SinOscFB.ar(p.midicps * r1, feed1, fm1);
	pm2 = SinOscFB.ar(p.midicps * r2, feed2, fm2);
	pm3 = SinOscFB.ar(p.midicps * r3, feed3, fm3);
	pm4 = SinOscFB.ar(p.midicps * r4, feed4, fm4);

	// Carrier with modulation applied from all 4 modulators
	sig = SinOsc.ar(p.midicps, pm1 + pm2 + pm3 + pm4);

	// Apply level control with proper scaling
	finalSig = sig * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "Complex 4-operator FM synthesizer with feedback", category: "Source/FM");
)