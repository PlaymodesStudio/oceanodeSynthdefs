(
~synthCreator.value("FMPerc", {|n|
	var sig, freq, car1, car2, mod1, mod2, mod3;
	var iscale, iEnv1, iEnv2, icurve, index1, index2;
	var m1Ratio, m2Ratio, m3Ratio, env;
	var fb, atk, rel, detune, mix, gate, drive, gain;
	var mod1fb, mod2fb, mod3fb, carfb, fbmod, carratio;
	var i1atk, i1rel, i2atk, i2rel;
	
	// Parameters with appropriate ranges
	freq = OceanodeParameterLag.ar(\freq, 60, n, 20, 1000, "vf", 1/30, true);
	index1 = OceanodeParameter.ar(\index1, 1, n, 0, 10, "vf");
	index2 = OceanodeParameter.ar(\index2, 2, n, 0, 10, "vf");
	iscale = OceanodeParameter.ar(\iscale, 0.04, n, 0.001, 0.5, "vf");
	icurve = OceanodeParameter.kr(\icurve, -8, n, -20, 0, "vf");
	atk = OceanodeParameter.ar(\atk, 0, n, 0, 1, "vf");
	rel = OceanodeParameter.ar(\rel, 1, n, 0.1, 10, "vf");
	detune = 2 ** (OceanodeParameter.kr(\detune, 10, n, 0, 100, "vf") / 1200);
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	m1Ratio = OceanodeParameter.ar(\m1ratio, 1, n, 0.1, 20, "vf");
	m2Ratio = OceanodeParameter.ar(\m2ratio, 12, n, 0.1, 20, "vf");
	m3Ratio = OceanodeParameter.ar(\m3ratio, 12, n, 0.1, 20, "vf");
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	
	// Additional parameters
	i1atk = OceanodeParameter.ar(\i1atk, 0.01, n, 0, 1, "vf");
	i1rel = OceanodeParameter.ar(\i1rel, 0.1, n, 0.01, 2, "vf");
	i2atk = OceanodeParameter.ar(\i2atk, 0.005, n, 0, 1, "vf");
	i2rel = OceanodeParameter.ar(\i2rel, 1, n, 0.01, 5, "vf");
	mod1fb = OceanodeParameter.ar(\mod1fb, 0, n, 0, 4, "vf");
	mod2fb = OceanodeParameter.ar(\mod2fb, 0, n, 0, 4, "vf");
	mod3fb = OceanodeParameter.ar(\mod3fb, 0, n, 0, 4, "vf");
	carfb = OceanodeParameter.ar(\carfb, 0, n, 0, 4, "vf");
	fbmod = OceanodeParameter.ar(\fbmod, 0.5, n, 0, 1, "vf");
	carratio = OceanodeParameter.ar(\carratio, 0.5, n, 0.1, 10, "vf");
	drive = OceanodeParameter.ar(\drive, 0, n, 0, 30, "vf");
	gain = OceanodeParameter.ar(\gain, 0, n, -20, 20, "vf");
	
	// Index of modulation envelopes - using multichannel expansion
	iEnv1 = EnvGen.kr(Env.perc(i1atk, i1rel * rel, icurve), gate: gate) * index1 * iscale;
	iEnv2 = EnvGen.kr(Env.perc(i2atk, i2rel * rel, icurve), gate: gate) * index2 * iscale;
	
	// Amplitude envelope - using multichannel expansion
	env = EnvGen.kr(Env.perc(atk, rel, curve: icurve), gate: gate);
	
	// Process each channel independently
	sig = Array.fill(n, {|i|
		var fb, mod1, mod2, mod3, car1, car2, channel_sig;
		
		// Get parameter values for this channel
		var ch_freq = freq[i];
		var ch_iEnv1 = iEnv1[i];
		var ch_iEnv2 = iEnv2[i];
		var ch_env = env[i];
		var ch_m1Ratio = m1Ratio[i];
		var ch_m2Ratio = m2Ratio[i];
		var ch_m3Ratio = m3Ratio[i];
		var ch_mod1fb = mod1fb[i];
		var ch_mod2fb = mod2fb[i];
		var ch_mod3fb = mod3fb[i];
		var ch_carfb = carfb[i];
		var ch_fbmod = fbmod[i];
		var ch_carratio = carratio[i];
		var ch_mix = mix[i];
		var ch_detune = detune[i];
		var ch_drive = drive[i];
		var ch_gain = gain[i];
		
		// Modulator/carrier with feedback for this channel
		fb = LocalIn.ar(2) * OceanodeParameter.ar(\feedback, 0, n, 0, 1, "vf")[i];
		fb = Rotate2.ar(fb[0], fb[1], ch_env.linlin(0, 1, -1, 1) * ch_fbmod);
		
		// FM synthesis chain for this channel
		mod1 = SinOscFB.ar(ch_freq * ch_m1Ratio, ch_mod1fb) * ch_freq * ch_m1Ratio * ch_iEnv1;
		mod2 = SinOscFB.ar(ch_freq * ch_m2Ratio, ch_mod2fb) * ch_freq * ch_m2Ratio * ch_iEnv1;
		mod3 = SinOscFB.ar([ch_freq, ch_freq * ch_detune] * (ch_m3Ratio + mod2 + mod1 + fb), ch_mod3fb) * ch_freq * ch_m3Ratio * ch_iEnv2;
		car1 = SinOscFB.ar([ch_freq, ch_freq * ch_detune] * ch_carratio + mod3, ch_carfb) * ch_env;
		car2 = mod3 * (index1[i] * iscale[i] * ch_m1Ratio * index2[i] * ch_m2Ratio * ch_m3Ratio * ch_freq).reciprocal * ch_env;
		
		// Mix carriers for this channel
		channel_sig = Mix.ar([SelectX.ar(ch_mix, [car1[0], car2[0]]), SelectX.ar(ch_mix, [car1[1], car2[1]])]);
		
		// Apply drive and clean up DC
		channel_sig = (channel_sig * ch_drive.dbamp).tanh;
		LocalOut.ar(LeakDC.ar(mod1 + mod2 + mod3 + car1, coef: 0.995));
		channel_sig = LeakDC.ar(channel_sig, coef: 0.995);
		
		// Apply gain
		channel_sig = channel_sig * ch_gain.dbamp;
	});
	
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Complex FM percussion with feedback network", category: "Source/Percussion");
)