(
~synthCreator.value("BinauralHaas", {|n|
	var input, output, position_x, position_y, position_z;
	var azimuth, distance, haas_delay, amplitude_diff;
	var left_signal, right_signal, level;
	var max_delay = 0.03; // Maximum delay time in seconds (30ms)

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Position parameters
	position_x = OceanodeParameterLag.ar(\xpos, 0, n, -1, 1, "vf", 1/30, true);
	position_y = OceanodeParameterLag.ar(\ypos, 0, n, -1, 1, "vf", 1/30, true);
	position_z = OceanodeParameterLag.ar(\zpos, 0, n, -1, 1, "vf", 1/30, true);

	// Level parameter
	level = OceanodeParameterLag.ar(\level, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Calculate distance (for attenuation)
	distance = sqrt((position_x * position_x) + (position_y * position_y) + (position_z * position_z));
	distance = max(distance, 0.1); // Avoid division by zero

	// Get delay time and pan amount
	haas_delay = position_x.abs * max_delay * OceanodeParameter.ar(\haas_amount, 1, n, 0, 1, "vf");

	// Use direct pan values scaled from -1 to 1 range
	amplitude_diff = position_x.abs * OceanodeParameter.ar(\pan_amount, 0.7, n, 0, 1, "vf");

	// Apply simple HRTF spectral cues based on position_z (elevation)
	input = BHiShelf.ar(
		input,
		OceanodeParameter.ar(\hrtf_freq, 6000, n, 1000, 12000, "vf"),
		0.7,
		position_z * -6 * OceanodeParameter.ar(\hrtf_amount, 0.5, n, 0, 1, "vf")
	);

	// Left channel processing - direct amplitude when sound is to the left, delayed when to the right
	left_signal = Mix([
		input * ((position_x <= 0) * (1 + amplitude_diff)),  // Louder when sound is to the left
		DelayL.ar(input, max_delay, haas_delay) * ((position_x > 0) * (1 - amplitude_diff))  // Delayed when sound is to the right
	]);

	// Right channel processing - direct amplitude when sound is to the right, delayed when to the left
	right_signal = Mix([
		input * ((position_x >= 0) * (1 + amplitude_diff)),  // Louder when sound is to the right
		DelayL.ar(input, max_delay, haas_delay) * ((position_x < 0) * (1 - amplitude_diff))  // Delayed when sound is to the left
	]);

	// Apply distance-based attenuation
	left_signal = left_signal * (1 / (1 + (distance * OceanodeParameter.ar(\distance_factor, 0.3, n, 0, 1, "vf"))));
	right_signal = right_signal * (1 / (1 + (distance * OceanodeParameter.ar(\distance_factor, 0.3, n, 0, 1, "vf"))));

	// Apply level control
	left_signal = left_signal * level;
	right_signal = right_signal * level;

	// Mix all channels down to a single stereo pair
	output = [Mix(left_signal), Mix(right_signal)];

	// Output the result as a single stereo signal at channels 0,1
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Mono to stereo binaural processor with Haas effect. It understands each input channel as a mono input and outputs all processed mono inputs as a stereo output", category: "Spatial/Perceptual");
)