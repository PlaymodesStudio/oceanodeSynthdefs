(
~synthCreator.value("Cymbal808", {|n|
	var decay, amp, tone, gate, env1, env2, env2b, env3, sum;
	
	// Parameters with appropriate ranges
	decay = OceanodeParameter.ar(\decay, 2, n, 0.1, 10, "vf");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	tone = OceanodeParameter.ar(\tone, 0.002, n, 0.0001, 0.01, "vf");
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	
	// Envelopes - using multichannel expansion
	env1 = EnvGen.ar(Env.perc(0.3, decay, curve: -3), gate);
	env2 = EnvGen.ar(Env.new([0, 0.6, 0], [0.1, decay*0.7], -5), gate);
	env2b = EnvGen.ar(Env.new([0, 0.3, 0], [0.1, decay*20], -120), gate);
	env3 = EnvGen.ar(Env.new([0, 1, 0], [0, decay*5], curve: -150), gate);
	
	// Process each channel independently
	sum = Array.fill(n, {|i|
		var ch_env1 = env1[i];
		var ch_env2 = env2[i];
		var ch_env2b = env2b[i];
		var ch_env3 = env3[i];
		var ch_amp = amp[i];
		var ch_tone = tone[i];
		var ch_sig, ch_sig1, ch_sig2, ch_sig2a, ch_sig2b, ch_sig3, ch_sum;
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
		
		// First component - low frequency
		ch_sig1 = BLowShelf.ar(ch_sig, 2000, 1, 5);
		ch_sig1 = BPF.ar(ch_sig1, 3000);
		ch_sig1 = BPeakEQ.ar(ch_sig1, 2400, 0.5, 5);
		ch_sig1 = BHiPass.ar(ch_sig1, 1550, 0.7);
		ch_sig1 = LPF.ar(ch_sig1, 3000);
		ch_sig1 = BLowShelf.ar(ch_sig1, 1000, 1, 0);
		ch_sig1 = ch_sig1 * ch_env1 * ch_tone;
		
		// Second component - mid frequency
		ch_sig2 = BLowShelf.ar(ch_sig, 990, 2, -5);
		ch_sig2 = BPF.ar(ch_sig2, 7400);
		ch_sig2 = BPeakEQ.ar(ch_sig2, 7200, 0.5, 5);
		ch_sig2 = BHiPass4.ar(ch_sig2, 6800, 0.7);
		ch_sig2 = BHiShelf.ar(ch_sig2, 10000, 1, -4);
		ch_sig2a = ch_sig2 * ch_env2 * 0.3;
		ch_sig2b = ch_sig2 * ch_env2b * 0.6;
		
		// Third component - high frequency
		ch_sig3 = BLowShelf.ar(ch_sig, 990, 2, -15);
		ch_sig3 = BPF.ar(ch_sig3, 6500);
		ch_sig3 = BPeakEQ.ar(ch_sig3, 7400, 0.35, 10);
		ch_sig3 = BHiPass4.ar(ch_sig3, 10500, 0.8, 2);
		ch_sig3 = ch_sig3 * ch_env3;
		
		// Mix all components
		ch_sum = ch_sig1 + ch_sig2a + ch_sig2b + ch_sig3;
		ch_sum = LPF.ar(ch_sum, 4000);
		ch_sum = ch_sum * ch_amp;
	});
	
	Out.ar(OceanodeOutput.kr(\out), sum);
}, description: "808 style cymbal with multiple resonant components", category: "Source/Percussion/808");
)