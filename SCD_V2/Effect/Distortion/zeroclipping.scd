(
~synthCreator.value("ZeroClipping", {|n|
	var input, preAmp, hardClipped, envelope, threshold, mode, mute, finalSig, release, attack, hardClip;

	// Input signal from Oceanode input bus
	input = In.ar(OceanodeInput.kr(\in), n);

	// Parameters
	preAmp = OceanodeParameter.ar(\pregain, 1, n, 0.1, 10, "vf");
	hardClip = OceanodeParameter.ar(\clip, 0.8, n, 0.01, 1, "vf");
	threshold = OceanodeParameter.ar(\threshold, 0.5, n, 0, 1, "vf");
	mode = OceanodeParameterDropdown.kr(\mode, 0, n, "Direct:Envelope");

	// Attack/release only used in envelope mode
	attack = OceanodeParameter.ar(\attack, 0.001, n, 0.0001, 0.3, "vf");
	release = OceanodeParameter.ar(\release, 0.01, n, 0.0001, 0.3, "vf");

	// Apply pre-gain and hard clipping
	hardClipped = (input * preAmp).clip2(hardClip);

	// Mode 0: Direct amplitude comparison
	// Mode 1: Envelope follower
	envelope = Select.ar(mode, [
		hardClipped.abs, // Direct amplitude
		Amplitude.ar(hardClipped, attack, release) // Envelope follower
	]);

	// Create mute signal: 1 when amplitude is below threshold, 0 when above
	mute = (envelope <= threshold);

	// Apply mute gate
	finalSig = hardClipped * mute;

	// Mix control for blend between processed and original signal
	finalSig = XFade2.ar(input, finalSig, OceanodeParameter.ar(\mix, 1, n, -1, 1, "vf"));

	// Level control with proper dB scaling
	finalSig = finalSig * OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Output the processed signal
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "Distortion with threshold clipping", category: "Effect/Distortion");
)