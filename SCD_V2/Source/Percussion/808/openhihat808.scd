(
~synthCreator.value("OpenHihat808", {|n|
	var decay, amp, env1, env2, gate, sum;
	
	// Parameters with appropriate ranges
	decay = OceanodeParameter.ar(\decay, 0.5, n, 0.1, 2, "vf");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	
	// Envelopes - using multichannel expansion
	env1 = EnvGen.ar(Env.perc(0.1, decay, curve: -3), gate);
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0, decay*5], curve: -150), gate);
	
	// Process each channel independently
	sum = Array.fill(n, {|i|
		var ch_env1 = env1[i];
		var ch_env2 = env2[i];
		var ch_amp = amp[i];
		var ch_sig, ch_siga, ch_sigb, ch_sum;
		var osc1, osc2, osc3, osc4, osc5, osc6;
		
		// Oscillator bank for this channel
		osc1 = LFPulse.ar(203.52) * 0.6;
		osc2 = LFPulse.ar(366.31) * 0.6;
		osc3 = LFPulse.ar(301.77) * 0.6;
		osc4 = LFPulse.ar(518.19) * 0.6;
		osc5 = LFPulse.ar(811.16) * 0.6;
		osc6 = LFPulse.ar(538.75) * 0.6;
		
		// Mix oscillators
		ch_sig = osc1 + osc2 + osc3 + osc4 + osc5 + osc6;
		
		// Filter and EQ
		ch_sig = BLowShelf.ar(ch_sig, 990, 2, -3);
		ch_sig = BPF.ar(ch_sig, 7700);
		ch_sig = BPeakEQ.ar(ch_sig, 7200, 0.5, 5);
		ch_sig = BHiPass4.ar(ch_sig, 8100, 0.7);
		ch_sig = BHiShelf.ar(ch_sig, 9400, 1, 5);
		
		// Apply envelopes
		ch_siga = ch_sig * ch_env1 * 0.6;
		ch_sigb = ch_sig * ch_env2;
		ch_sum = ch_siga + ch_sigb;
		
		// Final processing
		ch_sum = LPF.ar(ch_sum, 4000);
		ch_sum = ch_sum * ch_amp * 2;
	});
	
	Out.ar(OceanodeOutput.kr(\out), sum);
}, description: "808 style open hihat with pulse oscillator bank", category: "Source/Percussion/808");
)