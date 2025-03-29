(
~synthCreator.value("Flanger", {|n|
	var source, input, effect, sig, numchans, del, fb, mx, send;
	
	// All variables must be declared at the beginning
	numchans = n;
	
	// Parameters with appropriate ranges from synthdefs.json
	del = OceanodeParameter.ar(\delay, 0.005, n, 0, 0.02, "vf");
	fb = OceanodeParameter.ar(\feedback, 0.5, n, 0, 1, "vf");
	mx = OceanodeParameter.ar(\mix, 0, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	
	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply send amount
	input = source * send;
	
	// Create flanger effect with feedback
	input = input + LocalIn.ar(n);
	effect = DelayN.ar(input, 0.02, del);
	LocalOut.ar(effect * fb);
	
	// Mix dry and wet signals using XFade2
	sig = XFade2.ar(In.ar(OceanodeInput.kr(\in), n), effect, mx * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Flanger effect with feedback delay line", category: "Effect/Time/Phase");
)