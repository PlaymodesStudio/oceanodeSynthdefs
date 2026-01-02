(
~synthCreator.value("Maximizer", {|n, variables|
	var in, out, signal;
	var gain, gr, threshold, margin, character, preventISP;
	var envFollow, envFollowISP, lookAhead;
	var attack, release, inputGain, outputGain;
	var preventISPAmount = 0.2;

	// Parameters with OceanodeParameter
	threshold = OceanodeParameter.ar(\threshold, 0, n, -20, 0, "vf");
	margin = OceanodeParameter.ar(\margin, 0, n, -6, 0, "vf");
	character = OceanodeParameter.ar(\character, 4, n, 0, 10, "vf");
	preventISP = OceanodeParameterDropdown.kr(\preventisp, 0, n, "Off:On");

	// Get input signal
	in = In.ar(OceanodeInput.kr(\in), n);

	// Calculate parameter values based on controls
	attack = (character * 0.15).linexp(0, 1.5, 0.001, 0.05);  // Faster attack with higher character
	release = (character * 0.15).linexp(0, 1.5, 0.05, 0.8);  // Slower release with higher character

	// Convert threshold and margin to linear gain
	inputGain = threshold.dbamp.reciprocal;  // Inverse of threshold in linear domain
	outputGain = margin.dbamp;

	// Apply input gain
	signal = in * inputGain;

	// Look-ahead limiter implementation
	lookAhead = 0.005; // 5ms lookahead

	// Create an envelope follower with lookahead
	envFollow = DelayN.ar(signal, lookAhead, lookAhead);
	envFollow = Amplitude.ar(
		envFollow,
		attack,     // Attack time
		release     // Release time
	);

	// Calculate additional ISP detection if needed
	envFollowISP = HPF.ar(signal.abs, 10000) * preventISPAmount;

	// Mix in the inter-sample peak detection based on parameter (using Select)
	envFollow = Select.ar(
		preventISP,
		[
			envFollow,                  // 0 = Off
			envFollow + envFollowISP    // 1 = On
		]
	);

	// Calculate gain reduction
	gr = (envFollow.max(1.0)).reciprocal;

	// Soft knee limiting with character control
	gr = gr.pow(1.0 + (character * 0.05));

	// Apply gain reduction to delayed signal
	signal = DelayN.ar(signal, lookAhead, lookAhead) * gr;

	// Apply output gain
	signal = signal * outputGain;

	// Ensure no clipping and stability
	signal = LeakDC.ar(signal.clip(-0.99, 0.99));

	Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "Dynamic processor inspired by the Ozone 3 Maximizer", category: "Effect/Dynamics");
)