(
~synthCreator.value("Kickdrum", {|n|
	var body, bodyFreq, bodyAmp, gate, hi, lo, time1, time2, curv;
	var a, s, r, pmp, pmidx, waveType, amp;
	
	// Parameters with appropriate ranges
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	hi = OceanodeParameter.kr(\hifreq, 18000, n, 10000, 20000, "vf");
	lo = OceanodeParameterLag.ar(\lopitch, 36, n, 24, 60, "vf", 1/30, true).midicps;
	time1 = OceanodeParameter.ar(\freq1time, 0.035, n, 0, 1, "vf");
	time2 = OceanodeParameter.ar(\freq2time, 0.8, n, 0, 1, "vf");
	curv = OceanodeParameter.kr(\freqcurve, -8, n, -20, 0, "vf");
	a = OceanodeParameter.ar(\attack, 0, n, 0, 1, "vf");
	s = OceanodeParameter.ar(\sustain, 0.1, n, 0, 1, "vf");
	r = OceanodeParameter.ar(\release, 0.3, n, 0, 6, "vf");
	pmp = OceanodeParameter.ar(\pmpitch, 0, n, 0, 36, "vf").midicps;
	pmidx = OceanodeParameter.ar(\pmindex, 0, n, 0, 64, "vf");
	waveType = OceanodeParameterDropdown.kr(\wavetype, 0, n, "PM:Pulse");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	
	// Frequency and amplitude envelopes - using multichannel expansion
	bodyFreq = EnvGen.ar(Env([hi, hi, lo, lo], [0, time1, time2, time2], curve: curv), gate);
	bodyAmp = EnvGen.ar(Env.linen(a, s, r, curve: 'cubed'), gate);
	
	// Different waveforms with multichannel expansion
	// Select waveform per channel using multichannel expansion
	body = Select.ar(waveType, [
		PMOsc.ar(bodyFreq, bodyFreq - pmp, pmidx) * bodyAmp,
		Pulse.ar(bodyFreq) * bodyAmp
	]);
	
	// Process and apply amplitude
	body = body.tanh * amp;
	
	// Output directly - no need for wrapExtend as multichannel expansion handles this
	Out.ar(OceanodeOutput.kr(\out), body);
}, description: "Kick drum with frequency sweep and selectable waveform", category: "Source/Percussion");
)