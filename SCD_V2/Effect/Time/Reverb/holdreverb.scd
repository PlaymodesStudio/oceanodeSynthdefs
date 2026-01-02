(
~synthCreator.value("HoldReverb", {|n|
	var sig, local, wet, dry;

	// Input gain parameter with proper lag for smooth transitions
	var inputGain = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);

	// Feedback parameter with lag
	var feedback = OceanodeParameterLag.ar(\feedback, 0.5, n, 0, 1, "vf", 1/30, true);

	// Mix parameter with lag
	var mix = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);

	// Get input signal from the specified bus
	sig = In.ar(OceanodeInput.kr(\in), n) * inputGain;

	// Initialize the local signal buffer
	local = LocalIn.ar(n) + sig;

	// Apply the all-pass filter chain to each channel individually
	30.do {
		local = Array.fill(n, {|i|
			AllpassN.ar(local[i], 0.06, rrand(0.001, 0.06), 3);
		});
	};

	// Feedback the processed signal
	LocalOut.ar(local * feedback);

	// Prepare wet and dry signals
	wet = local * mix;
	dry = sig * (1 - mix);

	// Output the mix of dry and wet signals
	Out.ar(OceanodeOutput.kr(\out), wet + dry);
}, description: "Ambient reverb with infinite hold capabilities", category: "Effect/Time/Reverb");
)