(
~synthCreator.value("MembraneResonator", {|n|
	var p, signal, finalSig;
	var tension, loss, lossexp, exciterLevel, masterLevel, input, send, mix;
	var chanInput, wet;

	// Main parameters with lag for smooth transitions
	tension = OceanodeParameterLag.ar(\tension, 0.05, n, 0, 4, "vf", 1/30, true);
	loss = OceanodeParameterLag.ar(\loss, 2.9, n, 0.9, 4, "vf", 1/30, true);
	p = OceanodeParameterLag.ar(\pitch, 36, n, 0, 128, "vf", 1/30, true).midicps;

	// Amplitude parameters
	exciterLevel = OceanodeParameterLag.ar(\exciterlevel, 0.15, n, 0, 1, "vf", 1/30, true);
	masterLevel = OceanodeParameterLag.ar(\masterlevel, 0, n, 0, 1, "vf", 1/30, true);
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Map loss parameter to exponential scaling
	lossexp = LinLin.ar(loss, 0.9, 4.0, 0.9, 1.0);

	// Input for excitation
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate signal for each channel
	signal = n.collect({ |chan|
		chanInput = input[chan] * send[chan] * exciterLevel[chan];
		
		// Membrane physical model
		wet = MembraneCircle.ar(
			chanInput,
			tension[chan] * (p[chan] / 60.midicps),
			lossexp[chan]
		);
		
		// Apply master level with curve
		wet = wet * masterLevel[chan].lincurve(0, 1, 0, 1, 4);
		
		// Mix dry and wet signals
		XFade2.ar(input[chan], wet, mix[chan] * 2 - 1);
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), signal);

}, description: "Membrane resonator effect that applies circular membrane resonance to input audio", category: "Effect/Resonators");
)