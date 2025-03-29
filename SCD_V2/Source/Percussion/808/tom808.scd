(
~synthCreator.value("Tom808", {|n|
	var sig, baseFreq, gate, amp, tone, decayTime;
	var freqRange, envTimeRange, ampRange;
	
	// Parameters with appropriate ranges
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	baseFreq = OceanodeParameterLag.ar(\freq, 120, n, 40, 200, "vf", 1/30, true);
	tone = OceanodeParameter.ar(\tone, 0.5, n, 0, 1, "vf");
	decayTime = OceanodeParameter.ar(\decay, 0.5, n, 0.1, 2, "vf");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	
	// Map tone parameter (0-1) to frequency range (80-165) - using multichannel expansion
	freqRange = tone.linlin(0, 1, 80, 165);
	
	// Map tone parameter to envelope time range - using multichannel expansion
	envTimeRange = tone.linlin(0, 1, 20, 11);
	
	// Map tone parameter to amplitude range - using multichannel expansion
	ampRange = tone.linlin(0, 1, 3, 2);
	
	// Process each channel independently
	sig = Array.fill(n, {|i|
		var ch_gate = gate[i];
		var ch_tone = tone[i];
		var ch_freqRange = freqRange[i];
		var ch_envTimeRange = envTimeRange[i];
		var ch_ampRange = ampRange[i];
		var ch_decayTime = decayTime[i];
		var ch_amp = amp[i];
		var ch_env, ch_fenv, ch_sig;
		
		// Envelope with time based on tone
		// Changed to start at 0 instead of 0.4 to prevent auto-triggering
		ch_env = EnvGen.kr(
			Env.new([0, 1, 0], [0.001, ch_decayTime * ch_envTimeRange], [-4, -250]),
			ch_gate
		);
		
		// Frequency envelope with parameters based on tone
		// Using EnvGen to ensure it only triggers with gate
		ch_fenv = EnvGen.kr(
			Env(
				[
					ch_freqRange * ch_tone.linlin(0, 1, 1.25, 1.333333), 
					ch_freqRange * ch_tone.linlin(0, 1, 1.125, 1.121212), 
					ch_freqRange
				], 
				[0.1, 0.5], 
				-4
			),
			ch_gate
		);
		
		// Sound generation
		ch_sig = SinOsc.ar(ch_fenv, pi/2);
		ch_sig = ch_sig * ch_env * ch_amp * ch_ampRange;
	});
	
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "808 style tom with continuous tone control from low to high", category: "Source/Percussion/808");
)