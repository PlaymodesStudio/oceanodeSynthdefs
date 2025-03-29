(
~synthCreator.value("Notch", {|n|
	var freq, width, stages, filterType, signal, filtered, dry, mix, sig;

	// Parameters
	freq = OceanodeParameter.ar(\pitch, 90, n, 20, 135, "vf").midicps;
	width = OceanodeParameter.ar(\width, 50, n, 1, 1000, "vf");
	filterType = OceanodeParameterDropdown.kr(\type, 0, n, "CascadedBRF:Butterworth");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	
	// Fixed parameters
	stages = 6;

	// Input stage
	signal = In.ar(OceanodeInput.kr(\in), n);
	dry = signal;

	// Apply notch filtering
	filtered = n.collect({ |i|
		var channelSignal = signal[i];
		var rq = width[i] / freq[i];  // Convert width to rq for BRF
		var safeWidth = min(width[i], freq[i] * 1.95);  // Ensure width doesn't exceed frequency
		var lowFreq = max(20, freq[i] - (safeWidth/2));  // Ensure lower frequency is at least 20 Hz
		var highFreq = freq[i] + (safeWidth/2);
		
		Select.ar(filterType, [
			// Cascaded BRF
			stages.collect({
				channelSignal = BRF.ar(channelSignal, freq[i], rq);
			}).last,

			// Butterworth
			BHiShelf.ar(
				BLowShelf.ar(channelSignal, lowFreq, 1, -6.dbamp),
				highFreq, 1, -6.dbamp
			)
		]);
	});

	// Mix dry and wet signals
	sig = XFade2.ar(dry, filtered, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Notch filter with cascaded BRF and Butterworth implementations", category: "Effect/Filter");
)