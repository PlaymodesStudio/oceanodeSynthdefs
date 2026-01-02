(
~synthCreator.value("DWGFlute", {|n|
	var freq, amp, endReflection, jetReflection, jetDelayRatio, noiseGain;
	var lpf, hpf, vibA, vibF, contour, levels, vib, env, signal;

	// Control parameters
	freq = OceanodeParameterLag.ar(\pitch, 64, n, 0, 128, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true); // Keep as \amp since it's used for the instrument model
	endReflection = OceanodeParameterLag.ar(\endreflection, 0.45, n, 0, 1, "vf", 1/30, true);
	jetReflection = OceanodeParameterLag.ar(\jetreflection, 0.24, n, 0, 1, "vf", 1/30, true);
	jetDelayRatio = OceanodeParameterLag.ar(\jetdelayratio, 0.33, n, 0, 1, "vf", 1/30, true);
	noiseGain = OceanodeParameterLag.ar(\noisegain, 120, n, 0, 500, "vf", 1/30, true);
	lpf = OceanodeParameterLag.ar(\lpf, 5000, n, 20, 20000, "vf", 1/30, true);
	hpf = OceanodeParameterLag.ar(\hpf, 200, n, 20, 20000, "vf", 1/30, true);
	vibA = OceanodeParameterLag.kr(\viba, 0.03, n, 0, 1, "vf", 1/30, true);
	vibF = OceanodeParameterLag.kr(\vibf, 4, n, 0, 10, "vf", 1/30, true);
	contour = OceanodeParameterLag.ar(\contour, 1, n, 0, 2, "vf", 1/30, true);

	// Output level with proper curve scaling
	levels = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);

	// Create vibrato and noise components
	vib = SinOsc.kr(vibF, 0, vibA, 1);
	env = contour * (1.1 + (amp * 0.2)) * (vib + (0.001 * noiseGain * WhiteNoise.ar()));

	// Generate flute sound
	signal = DWGFlute.ar(freq, env, endReflection, jetReflection, jetDelayRatio, 1, 1000);

	// Apply filters
	signal = HPF.ar(LPF.ar(signal, lpf), hpf);

	// Output
	Out.ar(OceanodeOutput.kr(\out), signal * levels);
}, description: "Physical model of a flute instrument", category: "Source/PhysicalModelling");
)