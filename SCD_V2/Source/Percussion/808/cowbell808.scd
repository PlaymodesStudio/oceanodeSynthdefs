(
~synthCreator.value("Cowbell808", {|n|
	var sig, pul1, pul2, env, atk, atkenv, datk, gate, amp, atkDecay, mainDecay;
	
	// Parameters with appropriate ranges
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	atkDecay = OceanodeParameter.ar(\atkdecay, 1, n, 0.1, 5, "vf");
	mainDecay = OceanodeParameter.ar(\decay, 9.5, n, 0.1, 20, "vf");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	
	// Envelopes - using multichannel expansion
	atkenv = EnvGen.ar(Env.perc(0, atkDecay, 1, -215), gate);
	env = EnvGen.ar(Env.perc(0.01, mainDecay, 1, -90), gate);
	
	// Process each channel independently
	sig = Array.fill(n, {|i|
		var ch_atkenv = atkenv[i];
		var ch_env = env[i];
		var ch_amp = amp[i];
		var ch_pul1, ch_pul2, ch_atk, ch_datk, ch_sig;
		
		// Sound generation - two pulse oscillators
		ch_pul1 = LFPulse.ar(811.16);
		ch_pul2 = LFPulse.ar(538.75);
		
		// Attack and decay components
		ch_atk = (ch_pul1 + ch_pul2) * ch_atkenv * 6;
		ch_datk = (ch_pul1 + ch_pul2) * ch_env;
		
		// Mix and filter
		ch_sig = (ch_atk + ch_datk) * ch_amp;
		ch_sig = HPF.ar(ch_sig, 250);
		ch_sig = LPF.ar(ch_sig, 4500);
	});
	
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "808 style cowbell with dual pulse oscillators", category: "Source/Percussion/808");
)