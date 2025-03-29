(
~synthCreator.value("LFO", {|n|
	var p, ph, waves, pulsew, finalSig, poww, bipow;
	var k1, k2, k3, bip;

	// Basic LFO controls
	ph = OceanodeParameterLag.ar(\phoff, 0, n, 0, 1, "vf", 1/30, true);
	p = OceanodeParameterLag.ar(\freq, 1, n, 0.01, 20, "vf", 1/30, true);
	pulsew = OceanodeParameterLag.ar(\pw, 0.5, n, 0, 1, "vf", 1/30, true);
	poww = OceanodeParameterLag.ar(\pow, 1, n, 0.1, 4, "vf", 1/30, true);
	bipow = OceanodeParameterLag.ar(\bipow, 0, n, 0, 1, "vf", 1/30, true);

	// Create different waveforms
	waves = [
		// Saw wave
		(((((LFSaw.ar(p)+1)/2)+ph)%1)*2)-1,
		// Sine wave
		SinOsc.ar(p, ph * 2pi),
		// Triangle wave
		LFTri.ar(p, ph),
		// Pulse wave
		LFPulse.ar(p, ph, pulsew) * 2 - 1,
		// Noise
		LFDNoise3.ar(p)
	];

	// Select or interpolate between waveforms
	finalSig = SelectX.ar(OceanodeParameterFloatDropdown.kr(\shape, 0, n, "Saw:Sine:Triangle:Pulse:Noise"), waves);

	// Convert to unipolar [0,1] range for processing
	finalSig = (finalSig + 1) / 2;

	// Apply power transformation
	finalSig = finalSig.pow(poww);

	// Apply bipolar power transformation if needed
	finalSig = (finalSig * 2) - 1; // Convert to bipolar range [-1, 1]
	k1 = 2 * bipow * 0.99999;
	k2 = k1 / ((bipow * -1 * 0.999999) + 1);
	k3 = k2 * abs(finalSig) + 1;
	finalSig = finalSig * (k2 + 1) / k3; // Apply the non-linear transformation
	finalSig = (finalSig + 1) * 0.5; // Convert back to unipolar range [0, 1]

	// Handle bipolar output option
	bip=OceanodeParameter.ar(\bipolar, 0, n, 0, 1, "vi");
	finalSig = SelectX.ar(
		bip,
		[
			finalSig, // Unipolar [0,1]
			finalSig * 2 - 1 // Bipolar [-1,1]
		]
	);

	// Apply inversion option
	finalSig = SelectX.ar(
		OceanodeParameter.ar(\invert, 0, n, 0, 1, "vf"),
		[
			finalSig, // Normal
			SelectX.ar( // Inverted based on bipolar setting
				bip,
				[
					1 - finalSig, // Unipolar inversion
					finalSig * -1  // Bipolar inversion
				]
			)
		]
	);

	// Apply level control
	finalSig = finalSig * OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Output signal
	Out.ar(OceanodeOutput.kr(\out), finalSig);
}, description: "Low frequency oscillator with multiple waveforms and shaping options", category: "Modulation/LFO");
)