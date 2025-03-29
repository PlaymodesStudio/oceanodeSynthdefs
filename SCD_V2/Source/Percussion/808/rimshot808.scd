(
~synthCreator.value("Rimshot808", {|n|
	var env, sig, gate, amp, decayTime;
	
	// Parameters with appropriate ranges
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	decayTime = OceanodeParameter.ar(\decay, 0.07, n, 0.01, 0.5, "vf");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	
	// Envelope - using multichannel expansion
	// Changed to start at 0 instead of 1 to prevent auto-triggering
	env = EnvGen.ar(Env.new([0, 1, 0], [0.001, decayTime], [-4, -42]), gate);
	
	// Sound generation with multichannel expansion
	sig = Array.fill(n, {|i|
		var ch_env = env[i];
		var ch_amp = amp[i];
		var ch_tri1, ch_tri2, ch_punch, ch_sig;
		
		// Sound generation - triangle and pulse oscillators with noise
		ch_tri1 = LFTri.ar(1667 * 1.1, 1) * ch_env;
		ch_tri2 = LFPulse.ar(455 * 1.1, width: 0.8) * ch_env;
		ch_punch = WhiteNoise.ar * ch_env * 0.46;
		
		// Mix and filter
		ch_sig = ch_tri1 + ch_tri2 + ch_punch;
		ch_sig = BPeakEQ.ar(ch_sig, 464, 0.44, 8);
		ch_sig = HPF.ar(ch_sig, 315);
		ch_sig = LPF.ar(ch_sig, 7300);
		ch_sig = ch_sig * ch_amp;
	});
	
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "808 style rimshot with triangle pulse and noise components", category: "Source/Percussion/808");
)