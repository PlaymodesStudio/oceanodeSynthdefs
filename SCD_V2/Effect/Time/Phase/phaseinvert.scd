(
~synthCreator.value("PhaseInvert", {|n|
	var source, inverted, sig, numchans, invert, mx, send;
	
	// All variables must be declared at the beginning
	numchans = n;
	
	// Parameters with appropriate ranges from synthdefs.json
	invert = OceanodeParameter.ar(\invert, 0, n, 0, 1, "vi");
	mx = OceanodeParameter.ar(\mix, 0, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);
	
	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply send amount
	source = source * send;
	
	// Create phase inverted signal
	inverted = Select.ar(invert, [
		source,
		source * -1.0
	]);
	
	// Mix dry and wet signals using XFade2
	sig = XFade2.ar(In.ar(OceanodeInput.kr(\in), n), inverted, mx * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Inverts the phase of the input signal", category: "Effect/Time/Phase");
)