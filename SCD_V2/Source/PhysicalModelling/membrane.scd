(
~synthCreator.value("Membrane", {|n|
	var p, excitation, signal, finalSig, exmode;
	var tension, loss, lossexp, exciterLevel, masterLevel, input;

	// Excitation mode selector as dropdown
	exmode = OceanodeParameterDropdown.kr(\exciter, 0, n, "Internal:External");

	// Main parameters with lag for smooth transitions
	tension = OceanodeParameterLag.ar(\tension, 0.05, n, 0, 4, "vf", 1/30, true);
	loss = OceanodeParameterLag.ar(\loss, 2.9, n, 0.9, 4, "vf", 1/30, true);
	p = OceanodeParameterLag.ar(\pitch, 36, n, 0, 128, "vf", 1/30, true).midicps;

	// Amplitude parameters
	exciterLevel = OceanodeParameterLag.ar(\exciterlevel, 0.15, n, 0, 1, "vf", 1/30, true);
	masterLevel = OceanodeParameterLag.ar(\masterlevel, 0, n, 0, 1, "vf", 1/30, true);

	// Map loss parameter to exponential scaling
	lossexp = LinLin.ar(loss, 0.9, 4.0, 0.9, 1.0);

	// Input for external excitation
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate signal for each channel
	signal = n.collect({ |chan|
		// Select excitation source based on mode
		excitation = Select.ar(exmode[chan], [
			// Internal pink noise
			PinkNoise.ar(exciterLevel[chan]),
			// External input
			input[chan] * exciterLevel[chan]
		]);

		// Membrane physical model
		signal = MembraneCircle.ar(
			excitation,
			tension[chan] * (p[chan] / 60.midicps),
			lossexp[chan]
		);

		// Apply master level with curve
		signal * masterLevel[chan].lincurve(0, 1, 0, 1, 4)
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), signal);

}, description: "Circular membrane physical model with internal or external excitation", category: "Source/PhysicalModelling");
)