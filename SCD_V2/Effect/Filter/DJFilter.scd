(
~synthCreator.value("DJFilter", {|n|
	var input, wet, sig;
	var cutoff, mix, minCutoff, maxCutoff, lpfCut, hpfCut,width;

	// Get input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Define cutoff frequency range
	minCutoff = 20; // slightly higher than 10 for better audibility
	maxCutoff = 20000; // approximate Nyquist but more musical

	// Parameters
	cutoff = OceanodeParameterLag.ar(\cutoff, 0.5, n, 0, 1, "vf", 0.2, true);
	mix = OceanodeParameterLag.ar(\mix, 0.5, n, 0, 1, "vf", 0.1, true);
	width = OceanodeParameterLag.ar(\width, 0.1, n, 0, 0.4, "vf", 0.1, true);

	// Calculate filter cutoff frequencies
	lpfCut = cutoff.linexp(0, 0.5 + width, minCutoff, maxCutoff);
	hpfCut = cutoff.linexp(0.5 - width, 1.0, minCutoff, maxCutoff);

	// Apply filters
	wet = input;
	wet = HPF.ar(wet, hpfCut);
	wet = LPF.ar(wet, lpfCut);

	// Mix dry and wet signals
	sig = XFade2.ar(input, wet, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Crossfader filter with HPF and LPF", category: "Effect/Filter");
)

