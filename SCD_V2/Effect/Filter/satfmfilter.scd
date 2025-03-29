(
~synthCreator.value("SatFMFilter", {|n|
	var input, filteredHP, filteredLP, inputLPfm, inputHPfm, finalsig, drysig, mix;
	var lppitch, lpres, hppitch, hpres, lpfm, hpfm, drive;

	// Parameters with lag for smooth transitions
	lppitch = OceanodeParameterLag.ar(\lppitch, 90, n, 0, 130, "vf", 1/30, true).midicps;
	lpres = 1-(OceanodeParameterLag.ar(\lpres, 0.7, n, 0, 1, "vf", 1/30, true));
	hppitch = OceanodeParameterLag.ar(\hppitch, 20, n, 0, 130, "vf", 1/30, true).midicps;
	hpres = 1-(OceanodeParameterLag.ar(\hpres, 0.7, n, 0, 1, "vf", 1/30, true));
	lpfm = OceanodeParameterLag.ar(\lpfm, 0, n, 0, 3000, "vf", 1/30, true);
	hpfm = OceanodeParameterLag.ar(\hpfm, 0, n, 0, 3000, "vf", 1/30, true);
	drive = OceanodeParameterLag.ar(\dbdrive, 10, n, 0, 30, "vf", 1/30, true);
	mix = OceanodeParameterLag.ar(\drywet, 1, n, 0, 1, "vf", 1/30, true);

	// Get input from the bus
	input = In.ar(OceanodeInput.kr(\in), n);

	// Use input as FM source for both filters
	inputLPfm = input * lpfm;
	inputHPfm = input * hpfm;

	// Apply highpass filter with FM and saturation
	filteredHP = BHiPass4.ar(input, hppitch + inputHPfm, hpres, drive.dbamp).tanh;

	// Apply lowpass filter in series with FM
	filteredLP = BLowPass4.ar(filteredHP, lppitch + inputLPfm, lpres);

	// Final saturation and DC correction
	finalsig = LeakDC.ar(filteredLP, 0.995, drive.dbamp).tanh;

	// Store dry signal for mixing
	drysig = input;

	// Mix using XFade2 for constant power crossfade
	finalsig = XFade2.ar(drysig, finalsig, mix * 2 - 1);

	// Output the processed signal
	Out.ar(OceanodeOutput.kr(\out), finalsig);
}, description: "Serial HP LP FM filter with saturation", category: "Effect/Filter");
)