(
~synthCreator.value("Hat808", {|n|
	var decay, amp, sig, sighi, siglow, sum, env, osc1, osc2, osc3, osc4, osc5, osc6, gate;
	
	// Parameters with appropriate ranges
	decay = OceanodeParameter.ar(\decay, 0.42, n, 0.01, 2, "vf");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	
	// Envelope - using multichannel expansion
	env = EnvGen.ar(Env.perc(0.005, decay, 1, -30), gate);
	
	// Process each channel independently
	sig = Array.fill(n, {|i|
		var ch_env = env[i];
		var ch_amp = amp[i];
		var ch_sighi, ch_siglow, ch_sig;
		
		// Oscillator bank for this channel
		osc1 = LFPulse.ar(203.52);
		osc2 = LFPulse.ar(366.31);
		osc3 = LFPulse.ar(301.77);
		osc4 = LFPulse.ar(518.19);
		osc5 = LFPulse.ar(811.16);
		osc6 = LFPulse.ar(538.75);
		
		// Mix oscillators
		ch_sighi = (osc1 + osc2 + osc3 + osc4 + osc5 + osc6);
		ch_siglow = (osc1 + osc2 + osc3 + osc4 + osc5 + osc6);
		
		// Filter high and low components
		ch_sighi = BPF.ar(ch_sighi, 8900, 1);
		ch_sighi = HPF.ar(ch_sighi, 9000);
		ch_siglow = BBandPass.ar(ch_siglow, 8900, 0.8);
		ch_siglow = BHiPass.ar(ch_siglow, 9000, 0.3);
		
		// Final EQ and mix
		ch_sig = BPeakEQ.ar((ch_siglow + ch_sighi), 9700, 0.8, 0.7);
		ch_sig = ch_sig * ch_env * ch_amp;
	});
	
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "808 style closed hihat with pulse oscillator bank", category: "Source/Percussion/808");
)