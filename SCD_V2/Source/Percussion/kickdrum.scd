(
~synthCreator.value("KickDrum", {|n|
	var body, bodyFreq, bodyAmp, waves, go, hi, lo, time1, time2, curv, a, s, r, pmp, pmidx;

	// Trigger parameter
	go = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");

	// Frequency envelope parameters
	hi = OceanodeParameter.ar(\hifreq, 18000, n, 10, 20000, "vf");
	lo = OceanodeParameter.ar(\lopitch, 36, n, 12, 120, "vf").midicps;
	time1 = OceanodeParameter.ar(\freq1time, 0.035, n, 0, 1, "vf");
	time2 = OceanodeParameter.ar(\freq2time, 0.8, n, 0, 1, "vf");
	curv = OceanodeParameter.ar(\freqcurve, -8, n, -20, 20, "vf");

	// Amplitude envelope parameters
	a = OceanodeParameter.ar(\attack, 0, n, 0, 1, "vf");
	s = OceanodeParameter.ar(\sustain, 0.1, n, 0, 1, "vf");
	r = OceanodeParameter.ar(\release, 3, n, 0, 6, "vf");

	// Phase modulation parameters
	pmp = OceanodeParameter.ar(\pmpitch, 0, n, 0, 36, "vf").midicps;
	pmidx = OceanodeParameter.ar(\pmindex, 0, n, 0, 64, "vf");

	// Generate frequency and amplitude envelopes
	bodyFreq = EnvGen.ar(Env([hi, hi, lo, lo], [0, time1, time2, time2], curve: curv), Trig.ar(go, 0.01));
	bodyAmp = EnvGen.ar(Env.linen(a, s, r, curve: 'cubed'), Trig.ar(go, 0.01));

	// Wave selection
	waves = [
		PMOsc.ar(bodyFreq, bodyFreq - pmp, pmidx) * bodyAmp,
		Pulse.ar(bodyFreq) * bodyAmp
	];

	body = Select.ar(OceanodeParameterDropdown.kr(\wavetype, 0, n, "PMOsc:Pulse"), waves);
	body = body.tanh;

	// Output with level control
	Out.ar(OceanodeOutput.kr(\out), body);

}, description: "Kick drum synthesizer with envelope controlled frequency and phase modulation", category: "Source/Percussion");
)