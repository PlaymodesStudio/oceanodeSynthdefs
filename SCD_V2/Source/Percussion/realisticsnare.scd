(
~synthCreator.value("RealisticSnare", {|n|
	var gate, transp, transpw, transhp, transdec, transdb;
	var wnoisedec, wnoisedb, wnoisehp;
	var resohp, resolp, resofreq, resodb, resolength;
	var finaldec, finaleq, finalhp, amp, sig;
	
	// Parameters with appropriate ranges
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	transp = OceanodeParameter.kr(\transp, 139, n, 20, 1000, "vf");
	transpw = OceanodeParameter.ar(\transpw, 0.3, n, 0, 1, "vf");
	transhp = OceanodeParameter.kr(\transhp, 120, n, 20, 2000, "vf");
	transdec = OceanodeParameter.ar(\transdec, 0.079, n, 0, 10, "vf");
	transdb = OceanodeParameter.ar(\transdb, 3, n, -60, 60, "vf");
	
	wnoisedec = OceanodeParameter.ar(\wnoisedec, 10.17, n, 0, 20, "vf");
	wnoisedb = OceanodeParameter.ar(\wnoisedb, -3, n, -60, 60, "vf");
	wnoisehp = OceanodeParameter.kr(\wnoisehp, 300, n, 20, 2000, "vf");
	
	resohp = OceanodeParameter.kr(\resohp, 400, n, 20, 2000, "vf");
	resolp = OceanodeParameter.kr(\resolp, 3000, n, 20, 20000, "vf");
	resofreq = OceanodeParameter.kr(\resofreq, 550, n, 20, 2000, "vf");
	resodb = OceanodeParameter.ar(\resodb, -4.3, n, -60, 60, "vf");
	resolength = OceanodeParameter.ar(\resolength, 30.11, n, 0, 60, "vf");
	
	finaldec = OceanodeParameter.ar(\finaldec, 0.7, n, 0, 10, "vf");
	finaleq = OceanodeParameter.ar(\finaleq, 2.5, n, -20, 20, "vf");
	finalhp = OceanodeParameter.kr(\finalhp, 150, n, 20, 1000, "vf");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	
	// Process each channel independently
	sig = Array.fill(n, {|i|
		var ch_gate = gate[i];
		var ch_transp = transp[i];
		var ch_transpw = transpw[i];
		var ch_transhp = transhp[i];
		var ch_transdec = transdec[i];
		var ch_transdb = transdb[i];
		var ch_wnoisedec = wnoisedec[i];
		var ch_wnoisedb = wnoisedb[i];
		var ch_wnoisehp = wnoisehp[i];
		var ch_resohp = resohp[i];
		var ch_resolp = resolp[i];
		var ch_resofreq = resofreq[i];
		var ch_resodb = resodb[i];
		var ch_resolength = resolength[i];
		var ch_finaldec = finaldec[i];
		var ch_finaleq = finaleq[i];
		var ch_finalhp = finalhp[i];
		var ch_amp = amp[i];
		var ch_env, ch_transient, ch_resonance, ch_snare, ch_sig;
		
		// Main envelope
		ch_env = EnvGen.kr(Env.perc(0, ch_finaldec), ch_gate);
		
		// Transient component
		ch_transient = WhiteNoise.ar + Pulse.ar(ch_transp, ch_transpw);
		ch_transient = HPF.ar(ch_transient, ch_transhp);
		ch_transient = BPeakEQ.ar(ch_transient, [300, 1000], 1, [1.1, 0.6]);
		ch_transient = ch_transient * EnvGen.kr(Env.perc(0, ch_transdec), ch_gate) * ch_transdb.dbamp;
		
		// Noise component
		ch_snare = BPeakEQ.ar(WhiteNoise.ar, 2000, 0, 6.3) * EnvGen.kr(Env.perc(0, ch_wnoisedec), ch_gate) * ch_wnoisedb.dbamp;
		ch_snare = HPF.ar(ch_snare, ch_wnoisehp);
		
		// Resonance component with feedback
		ch_resonance = ch_transient + LocalIn.ar(1);
		ch_resonance = DelayC.ar(ch_resonance, 0.4, 0.01152);
		ch_resonance = HPF.ar(ch_resonance, ch_resohp);
		ch_resonance = LPF.ar(ch_resonance, ch_resolp);
		ch_resonance = BPeakEQ.ar(ch_resonance, ch_resofreq, 1.3, ch_resodb);
		ch_resonance = ch_resonance * ch_resolength.dbamp;
		LocalOut.ar(ch_resonance);
		ch_resonance = ch_resonance * -4.5.dbamp;
		
		// Mix components
		ch_sig = ch_transient + ch_resonance + ch_snare;
		ch_sig = ch_sig + JPverb.ar(ch_sig * -20.dbamp).sum;
		ch_sig = BPeakEQ.ar(ch_sig, 900, 1, ch_finaleq);
		ch_sig = HPF.ar(ch_sig, ch_finalhp);
		ch_sig = (ch_sig * 1.6).tanh * 0.7;
		ch_sig = ch_sig * ch_env * ch_amp * -10.dbamp;
	});
	
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Realistic snare with transient noise and resonance components", category: "Source/Percussion");
)