
(
~synthCreator.value("FMGrain", {|n|
    var t,gain,buf,car,mod,dur,sig,amp,idx,envbuf;
	t = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
    gain = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	amp = OceanodeParameterLag.ar(\amp, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    buf = OceanodeBuffer.kr(\envbuf);
    car = OceanodeParameter.ar(\car, 36, n, 0, 130, "vf").midicps;
    mod = OceanodeParameter.ar(\mod, 38, n, 0, 130, "vf").midicps;
	idx = OceanodeParameter.ar(\idx, 1, n, 0, 20, "vi");
    dur = OceanodeParameter.ar(\grainsize, 0.1, n, 0.01, 1, "vf");

	sig=GrainFM.ar(
		numChannels: 1,
		trigger: t,
		dur: dur,
		carfreq: car,
		modfreq: mod,
		index: idx,
		pan: 0,
		envbufnum: buf,
		mul: amp
	);
    Out.ar(OceanodeOutput.kr(\out),sig);
}, description: "Basic granular synth with frequency modulated sine tones", category: "Source/FM");
)