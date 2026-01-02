(
~synthCreator.value("BandpassFilter", {|n|
	var input, output, levels;
	var pitch, freq, q, amp;

	// Get input from the bus
	input = In.ar(OceanodeInput.kr(\in), n);

	// Parameter controls with proper lag for smooth transitions
	pitch = OceanodeParameterLag.ar(\pitch, 60, n, 0, 130, "vf", 1/30, true);
	freq = pitch.midicps;
	q = 1-(OceanodeParameterLag.ar(\q, 1, n, 0.005, 1, "vf", 1/30, true));
	amp = OceanodeParameterLag.ar(\amp, 1, n, 0, 1, "vf", 1/30, true);

	// Level control with proper dB scaling
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Apply two BPFs in series for steeper filtering
	output = input;
	output = BPF.ar(output, freq, q);
	output = BPF.ar(output, freq, q);

	// Apply amplitude and level controls
	output = output * amp * levels;

	// Output the processed signal
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "2 pole bandpass filter", category: "Effect/Filter");
)