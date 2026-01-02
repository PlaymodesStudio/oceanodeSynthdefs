(
~synthCreator.value("RingmodSidechain", {|n|
	var input, sidechain, dry, wet;
	var rectified, ringmod_out, final_out;
	var mix, levels;

	// Input from bus (target signal to be ducked)
	input = In.ar(OceanodeInput.kr(\in), n);

	// Sidechain input (trigger signal, typically drums)
	sidechain = In.ar(OceanodeInput.kr(\sidechain), n);

	// Keep dry signal for mix later
	dry = input;

	// Step 1: Rectify the sidechain signal negatively
	// This converts bipolar signal to unipolar negative
	rectified = sidechain.abs.neg;

	// Step 2: Ring modulation - multiply rectified sidechain with input
	// This creates the "carved out" signal
	ringmod_out = input * rectified;

	// Step 3: Sum the ring modulated signal with original input
	// This implements: output = input + (rectified * input)
	final_out = input + ringmod_out;

	// Apply gain compensation to prevent overs
	final_out = final_out * OceanodeParameterLag.ar(\gain, 0.7, n, 0, 1, "vf", 1/30, true);

	// Optional: Apply some smoothing to reduce artifacts
	final_out = LeakDC.ar(final_out);

	// Mix dry/wet using XFade2
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);
	wet = XFade2.ar(dry, final_out, (mix * 2) - 1);

	// Apply final level control
	wet = wet * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Send to output bus
	Out.ar(OceanodeOutput.kr(\out), wet);
}, description: "Ring modulation sidechain ducking effect that carves out frequency content at audio rate", category: "Effect/Dynamics");
)