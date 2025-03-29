(
~synthCreator.value("CustomResonator512_", {|n|
	var partials = 512;
	var freqs, decays, amps, pans, input, send, mix, levels, width;
	var sig, largeSig, mixedSig, wet;
	
	// Define parameters
	freqs = OceanodeParameterLag.kr(\freqarray, 220, partials*n, 20, 20000, "vf", 1/30, true);
	decays = OceanodeParameterLag.kr(\decayarray, 0.5, partials*n, 0.01, 10, "vf", 1/30, true);
	amps = OceanodeParameterLag.kr(\amparray, 0.0, partials*n, 0, 1, "vf", 1/30, true);
	pans = OceanodeParameterLag.kr(\panarray, 0.5, partials*n, 0, 1, "vf", 1/30, true);
	
	// Width parameter for spatial spread
	width = OceanodeParameter.kr(\width, 2, 1, 0.5, 8, "f", 1/30, true);
	
	// Levels for each output channel
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	
	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);
	
	// Reshape parameter arrays for multichannel processing
	freqs = freqs.reshape(n, partials).flop;
	decays = decays.reshape(n, partials).flop;
	amps = amps.reshape(n, partials).flop;
	pans = pans.reshape(n, partials).flop;
	
	// Process each channel with resonators
	if(n == 1) {
		// For mono, no panning needed
		largeSig = input * send;
		largeSig = Mix.ar(Array.fill(partials, { |i|
			Ringz.ar(largeSig, freqs[i][0], decays[i][0], amps[i][0]);
		})) * levels;
	} {
		if(n == 2) {
			// For stereo, use Pan2
			largeSig = n.collect({ |chan|
				var chanInput = input[chan] * send[chan];
				var resonators = Array.fill(partials, { |i|
					var resonator = Ringz.ar(chanInput, freqs[i][chan], decays[i][chan], amps[i][chan]);
					Pan2.ar(resonator, pans[i][chan] * 2 - 1)[chan]; // Only take the channel we need
				});
				Mix.ar(resonators) * levels[chan];
			});
		} {
			// For multichannel, use PanAz
			largeSig = n.collect({ |chan|
				var chanInput = input[chan] * send[chan];
				var resonators = Array.fill(partials, { |i|
					var resonator = Ringz.ar(chanInput, freqs[i][chan], decays[i][chan], amps[i][chan]);
					PanAz.ar(n, resonator, pans[i][chan] * 2 - 1, 1, width, 0)[chan]; // Only take the channel we need
				});
				Mix.ar(resonators) * levels[chan];
			});
		};
	};
	
	// Apply wet/dry mix
	sig = n.collect({ |chan|
		XFade2.ar(input[chan], largeSig[chan], mix[chan] * 2 - 1);
	});
	
	// Output the final signal
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Resonator effect with 512 tunable resonators applied to input audio",
   category: "Effect/Resonators");
)