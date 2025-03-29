(
~synthCreator.value("AbstractDrum", {|n|
	var t_gate, freq, amp, att, dec, rel, position, ampSlope, decCoef, hiFreqSus;
	var freqarray, amparray, decarray, exciter, snd, env, levels;
	
	// Named controls with appropriate parameter types
	t_gate = OceanodeParameter.kr(\gate, 0, n, 0, 1, "vi");
	freq = OceanodeParameterLag.ar(\pitch, 60, n, 24, 96, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.kr(\amp, 1, n, 0, 2, "vf", 1/30, true);
	att = OceanodeParameterLag.kr(\att, 0.001, n, 0, 0.1, "vf", 1/30, true);
	dec = OceanodeParameterLag.kr(\dec, 0.01, n, 0, 0.1, "vf", 1/30, true);
	rel = OceanodeParameterLag.kr(\rel, 1, n, 0.1, 10, "vf", 1/30, true);
	position = OceanodeParameterLag.kr(\pos, 0.5, n, 0, 1, "vf", 1/30, true);
	ampSlope = OceanodeParameterLag.kr(\ampslope, 3, n, 0, 10, "vf", 1/30, true);
	decCoef = OceanodeParameterLag.kr(\deccoef, 0.15, n, 0, 1, "vf", 1/30, true);
	hiFreqSus = OceanodeParameterLag.kr(\hifreqsus, 0, n, 0, 1, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	
	// Process each channel independently
	snd = Array.fill(n, {|i|
		var ch_freqarray, ch_amparray, ch_decarray, ch_exciter, ch_snd, ch_env;
		
		// Get parameter values for this channel
		var ch_t_gate = t_gate[i];
		var ch_freq = freq[i];
		var ch_amp = amp[i];
		var ch_att = att[i];
		var ch_dec = dec[i];
		var ch_rel = rel[i];
		var ch_position = position[i];
		var ch_ampSlope = ampSlope[i];
		var ch_decCoef = decCoef[i];
		var ch_hiFreqSus = hiFreqSus[i];
		var ch_levels = levels[i];
		
		// Setting up arrays for Klank for this channel
		ch_freqarray = Array.fill(8, {
			arg j = 1;
			(
				Array.fill((j + 1), {
					arg k;
					(k + 1).pow(2)
				}) +
				(j + 1).pow(2)
			).sqrt
		});
		ch_freqarray = ch_freqarray.flatten/(2.sqrt);
		
		ch_amparray = Array.fill(36, {
			arg j;
			if (ch_freqarray[j] > 20000) {
				0
			} {
				sin(((j + 1) * pi) * ch_position) *
				(ch_ampSlope * (ch_freqarray[j]).log2).dbamp
			}
		});
		ch_amparray = ch_amparray/ch_ampSlope;
		
		ch_decarray = Array.fill(36, {
			arg j;
			exp(-1 * j * ch_decCoef) + ch_hiFreqSus
		});
		ch_decarray = ch_decarray/ch_decarray[0];
		
		// Envelope for gating
		ch_env = EnvGen.kr(Env.asr(ch_att, 1, ch_rel), gate: ch_t_gate);
		
		// Exciter (retriggerable)
		ch_exciter = Decay2.ar(
			in: T2A.ar(ch_t_gate),
			attackTime: ch_att,
			decayTime: ch_dec,
			mul: 0.005);
		
		// The actual sound-making part
		ch_snd = DynKlank.ar(
			specificationsArrayRef: Ref.new([ch_freqarray, ch_amparray, ch_decarray]),
			input: ch_exciter,
			freqscale: ch_freq,
			decayscale: ch_rel);
		
		// Output processing for this channel
		ch_snd = Mix.ar(ch_snd * ch_amp * 2);
		ch_snd = Limiter.ar(ch_snd);
		ch_snd = ch_snd * ch_env;
		
		// Final level control with proper dB scaling
		ch_snd = ch_snd * ch_levels;
	});
	
	Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "Physical modeling percussion with modal synthesis", category: "Source/Percussion");
)