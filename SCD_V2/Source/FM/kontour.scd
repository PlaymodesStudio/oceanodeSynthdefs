(
~synthCreator.value("Kontour", {|n|
	var feedback, sig, sig2;

	// Parameters with lag for smooth transitions
	var phFeed1 = OceanodeParameterLag.ar(\phfeed1, 0.5, n, 0, 3, "vf", 1/30, true);
	var modAmp = OceanodeParameterLag.ar(\modamp, 1, n, 0, 6, "vf", 1/30, true);
	var levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	var pitch1 = OceanodeParameterLag.ar(\pitch1, 24, n, 0, 130, "vf", 1/30, true).midicps;
	var pitch2 = OceanodeParameterLag.ar(\pitch2, 60, n, 0, 130, "vf", 1/30, true).midicps;
	var phLP = OceanodeParameterLag.ar(\phlp, 130, n, 0, 130, "vf", 1/30, true).midicps;
	var shaper1 = OceanodeParameterLag.ar(\shaper1, 1, n, 0, 16, "vf", 1/30, true);
	var shaper2 = OceanodeParameterLag.ar(\shaper2, 1, n, 0, 16, "vf", 1/30, true);

	// Feedback loop
	feedback = LPF.ar(LocalIn.ar(n), phLP);
	feedback = (feedback * shaper1).sin;

	// Modulator oscillator with waveshaping
	sig2 = SinOsc.ar(pitch2);
	sig2 = (sig2 * shaper2).sin;
	sig2 = sig2 * modAmp;

	// Carrier oscillator with phase modulation from both feedback and modulator
	sig = SinOsc.ar(pitch1, (feedback * phFeed1) + sig2).tanh;

	// Complete the feedback loop
	LocalOut.ar(sig);

	// Output with final tanh limiting and level control
	Out.ar(OceanodeOutput.kr(\out), levels * sig.tanh);
}, description: "Complex phase modulation oscillator with feedback", category: "Source/FM");
)