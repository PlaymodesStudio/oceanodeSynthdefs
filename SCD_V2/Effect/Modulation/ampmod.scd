(
~synthCreator.value("AmpMod", {|n|
	var input, modulated, sig, p, amt, mix, waveType, pw, waves, carrier;

	// Parameters with lag for smooth transitions
	p = OceanodeParameterLag.ar(\pitch, 72, n, 12, 120, "vf", 1/30, true).midicps;
	amt = OceanodeParameterLag.ar(\strength, 1, n, 0, 4, "vf", 1/30, true);
	mix = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);
	waveType = OceanodeParameterDropdown.kr(\type, 0, n, "Sine:Triangle:Pulse:Saw:ISaw");
	pw = OceanodeParameterLag.ar(\pw, 0.5, n, 0, 1, "vf", 1/30, true);

	// Get input from the bus
	input = In.ar(OceanodeInput.kr(\in), n);

	// Define different wave shapes
	waves = [
		SinOsc.ar(p, 0, 1, 0),            // Sine
		LFTri.ar(p, 0, 1, 0),             // Triangle
		LFPulse.ar(p, 0, pw, 1, 0),       // Pulse with width control
		Saw.ar(p, 1, 0),                  // Saw
		Saw.ar(p, 1, 0).neg        // InvSaw
	];

	// Select the carrier wave based on the waveType parameter
	carrier = Select.ar(waveType, waves);

	// Apply amplitude modulation - normalized to 0-1 range
	modulated = input * (((carrier + 1) / 2) * amt);
	modulated = modulated.tanh;

	// Mix using XFade2 for constant power crossfade
	sig = XFade2.ar(input, modulated, mix * 2 - 1);

	// Apply level scaling with proper curve for natural control
	sig = sig * OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Output the processed signal
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Amplitude modulator with multiple waveforms and controls", category: "Effect/Modulation");
)