(
~synthCreator.value("GateDuration", {|n|
	var input, duration, gate, trig, env;

	// Audio input for impulse triggers
	input = In.ar(OceanodeInput.kr(\in), n);

	// Duration parameter in milliseconds
	duration = OceanodeParameter.ar(\duration, 100, n, 1, 10000, "vf");

	// Detect impulses (triggers when input goes from 0 to 1)
	trig = Trig1.ar(input, 0.001);

	// Create envelope generator that sustains for the duration
	env = EnvGen.ar(
		Env.new([0, 1, 1, 0], [0, duration * 0.001, 0], \lin),
		gate: trig
	);

	// Output the gate signal
	Out.ar(OceanodeOutput.kr(\out), env);

}, description: "Gate sustainer that converts impulses to sustained gates", category: "Modulation/Trigger");
)