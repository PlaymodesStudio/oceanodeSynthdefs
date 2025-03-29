(
~synthCreator.value("Delay", {|n|
	var input, output, delayms, delaytime, mix;
	
	// Parameters
	delayms = OceanodeParameter.ar(\delayms, 0, n, 0, 1000, "vf");
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	
	// Convert milliseconds to seconds
	delaytime = delayms / 1000;
	
	// Input processing
	input = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply delay
	output = DelayC.ar(input, 24, delaytime);
	
	// Mix dry and wet signals
	output = XFade2.ar(input, output, mix * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Simple delay effect with variable delay time", category: "Effect/Time/Delay", variables: [], variableDimensions: []);
)