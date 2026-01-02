(
~synthCreator.value("Click", {|n|
	var go, env, click;

	// Trigger signal
	go = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");

	// Generate envelope from trigger
	env = EnvGen.ar(Env(#[0, 0, 1], [0, 1], 0), go);

	// Create click from envelope transitions
	click = Changed.ar(ceil(env));

	// Apply level control with proper dB scaling
	click = click * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), click);

}, description: "Click generator triggered by input signal", category: "Source/Noise");
)