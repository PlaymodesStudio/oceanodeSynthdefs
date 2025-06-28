(
~synthCreator.value("Vibrato", {|n|
	var sigout, sig, mod1, depth, mfreq, mix, phaseoffset, phasereset, phase;
	// Parameters
	depth = OceanodeParameterLag.ar(\depth, 0.1, n, 0, 0.5, "vf", 1/30, true);
	mfreq = OceanodeParameterLag.ar(\freq, 5, n, 0.1, 20, "vf", 1/30, true);
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);
	phaseoffset = OceanodeParameterLag.ar(\ph_offset, 0, n, 0, 2*pi, "vf", 1/30, true);
	phasereset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");
	// Input stage
	sig = In.ar(OceanodeInput.kr(\in), n);
	// Phase calculation with reset capability
	phase = Phasor.ar(phasereset > 0.5, mfreq * 2*pi / SampleRate.ir, 0, 2*pi) + phaseoffset;
	// Create vibrato effect using calculated phase
	mod1 = sin(phase) * depth + depth;
	sigout = DelayC.ar(sig, 0.2, mod1);
	// Mix dry and wet signals
	sigout = XFade2.ar(sig, sigout, mix * 2 - 1);
	// Output
	Out.ar(OceanodeOutput.kr(\out), sigout);
}, description: "Vibrato effect with adjustable rate, depth, phase offset, and phase reset", category: "Effect/Modulation");
)