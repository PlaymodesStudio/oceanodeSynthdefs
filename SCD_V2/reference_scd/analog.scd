(
~synthCreator.value("Analog", {|n|
	var p, pulsew, finalSig, waves, freq, vib, trem, tremRate, tremAmount, vibRate, vibAmount;

	// Main pitch control with lag for smooth transitions
	p = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true);
	pulsew = OceanodeParameter.ar(\pw, 0, n, 0, 1, "vf");

	// Tremolo and vibrato parameters
	tremRate = OceanodeParameterLag.ar(\tremf, 0, n, 0, 8, "vf", 1/30, true);
	tremAmount = OceanodeParameterLag.ar(\trema, 0, n, 0, 1, "vf", 1/30, true);
	vibRate = OceanodeParameterLag.ar(\vibf, 0, n, 0, 8, "vf", 1/30, true);
	vibAmount = OceanodeParameterLag.ar(\viba, 0, n, 0, 1, "vf", 1/30, true);

	// Apply vibrato to pitch
	vib = SinOsc.ar(vibRate, 0, vibAmount, 0);
	p = (p + vib).midicps;

	// Define waveforms including the new impulse oscillator
	waves = [
		Saw.ar(p, 1, 0),
		LFTri.ar(p, 0),
		Pulse.ar(p, (pulsew+0.5)%1, 1),
		SinOsc.ar(p, 0),
		Impulse.ar(p, 0)  // Added Impulse oscillator
	];

	// Updated dropdown options to include Impulse
	finalSig = Select.ar(OceanodeParameterDropdown.kr(\type, 0, n, "Saw:Triangle:Pulse:Sine:Impulse"), waves);

	// Apply tremolo to amplitude
	trem = 1 - ((SinOsc.ar(tremRate, 0, 1, 1) / 2) * tremAmount);

	// Apply level control with proper dB scaling
	finalSig = finalSig * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4) * trem;

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "Analog synth with different wave types", category: "Source/Analog");
)