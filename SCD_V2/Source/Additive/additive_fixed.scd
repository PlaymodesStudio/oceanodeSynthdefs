(
// Additive synthesis with multiple oscillator counts

// 32 oscillators
~synthCreator.value("Additive32_", {|n|
	var partials = 32;
	var pitch, amps, pans, levels, sigArray, mixedSig, usedpartials, width;

	// Define parameters
	pitch = OceanodeParameter.kr(\pitcharray, 36, partials, 0, 127, "vf").midicps;
	amps = OceanodeParameterLag.kr(\amparray, 0.0, partials, 0, 1, "vf", 1/30, true);
	pans = OceanodeParameterLag.kr(\panarray, 0.0, partials, 0, 1, "vf", 1/30, true);

	// Width parameter for spatial spread
	width = OceanodeParameter.kr(\width, 2, 1, 0.5, 8, "f", 1/30, true);

	// Levels for each output channel
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Create an array of oscillators with special handling for stereo
	sigArray = Array.fill(partials, { |i|
		var baseFreq = pitch[i];
		var amp = amps[i];
		var sig = SinOsc.ar(baseFreq, Rand(-25, 25), amp);

		if(n == 1) {
			// For mono, no panning needed
			[sig]
		} {
			if(n == 2) {
				// For stereo, use Pan2 which has the behavior we want
				// 0->left, 1->right, 0.5->center
				Pan2.ar(sig, pans[i] * 2 - 1)
			} {
				// For more than 2 channels, use PanAz with orientation 0
				PanAz.ar(n, sig, pans[i] * 2 - 1, 1, width, 0)
			}
		}
	});

	// Mix down to the number of output channels
	mixedSig = Array.fill(n, { |chan|
		Mix.new(sigArray.collect { |sig| sig[chan] });
	});

	// Apply levels after mixing
	mixedSig = mixedSig * levels;

	// Output the final signal with normalized amplitude
	Out.ar(OceanodeOutput.kr(\out), mixedSig / partials);

}, description: "Additive synthesis with 32 sinusoidal oscillators",
   category: "Source/Additive");

// 64 oscillators
~synthCreator.value("Additive64_", {|n|
	var partials = 64;
	var pitch, amps, pans, levels, sigArray, mixedSig, usedpartials, width;

	// Define parameters
	pitch = OceanodeParameter.kr(\pitcharray, 36, partials, 0, 127, "vf").midicps;
	amps = OceanodeParameterLag.kr(\amparray, 0.0, partials, 0, 1, "vf", 1/30, true);
	pans = OceanodeParameterLag.kr(\panarray, 0.0, partials, 0, 1, "vf", 1/30, true);

	// Width parameter for spatial spread
	width = OceanodeParameter.kr(\width, 2, 1, 0.5, 8, "f", 1/30, true);

	// Levels for each output channel
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Create an array of oscillators with special handling for stereo
	sigArray = Array.fill(partials, { |i|
		var baseFreq = pitch[i];
		var amp = amps[i];
		var sig = SinOsc.ar(baseFreq, Rand(-25, 25), amp);

		if(n == 1) {
			// For mono, no panning needed
			[sig]
		} {
			if(n == 2) {
				// For stereo, use Pan2 which has the behavior we want
				// 0->left, 1->right, 0.5->center
				Pan2.ar(sig, pans[i] * 2 - 1)
			} {
				// For more than 2 channels, use PanAz with orientation 0
				PanAz.ar(n, sig, pans[i] * 2 - 1, 1, width, 0)
			}
		}
	});

	// Mix down to the number of output channels
	mixedSig = Array.fill(n, { |chan|
		Mix.new(sigArray.collect { |sig| sig[chan] });
	});

	// Apply levels after mixing
	mixedSig = mixedSig * levels;

	// Output the final signal with normalized amplitude
	Out.ar(OceanodeOutput.kr(\out), mixedSig / partials);

}, description: "Additive synthesis with 64 sinusoidal oscillators",
   category: "Source/Additive");

// 128 oscillators
~synthCreator.value("Additive128_", {|n|
	var partials = 128;
	var pitch, amps, pans, levels, sigArray, mixedSig, usedpartials, width;

	// Define parameters
	pitch = OceanodeParameter.kr(\pitcharray, 36, partials, 0, 127, "vf").midicps;
	amps = OceanodeParameterLag.kr(\amparray, 0.0, partials, 0, 1, "vf", 1/30, true);
	pans = OceanodeParameterLag.kr(\panarray, 0.0, partials, 0, 1, "vf", 1/30, true);

	// Width parameter for spatial spread
	width = OceanodeParameter.kr(\width, 2, 1, 0.5, 8, "f", 1/30, true);

	// Levels for each output channel
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Create an array of oscillators with special handling for stereo
	sigArray = Array.fill(partials, { |i|
		var baseFreq = pitch[i];
		var amp = amps[i];
		var sig = SinOsc.ar(baseFreq, Rand(-25, 25), amp);

		if(n == 1) {
			// For mono, no panning needed
			[sig]
		} {
			if(n == 2) {
				// For stereo, use Pan2 which has the behavior we want
				// 0->left, 1->right, 0.5->center
				Pan2.ar(sig, pans[i] * 2 - 1)
			} {
				// For more than 2 channels, use PanAz with orientation 0
				PanAz.ar(n, sig, pans[i] * 2 - 1, 1, width, 0)
			}
		}
	});

	// Mix down to the number of output channels
	mixedSig = Array.fill(n, { |chan|
		Mix.new(sigArray.collect { |sig| sig[chan] });
	});

	// Apply levels after mixing
	mixedSig = mixedSig * levels;

	// Output the final signal with normalized amplitude
	Out.ar(OceanodeOutput.kr(\out), mixedSig / partials);

}, description: "Additive synthesis with 128 sinusoidal oscillators",
   category: "Source/Additive");

// 256 oscillators
~synthCreator.value("Additive256_", {|n|
	var partials = 256;
	var pitch, amps, pans, levels, sigArray, mixedSig, usedpartials, width;

	// Define parameters
	pitch = OceanodeParameter.kr(\pitcharray, 36, partials, 0, 127, "vf").midicps;
	amps = OceanodeParameterLag.kr(\amparray, 0.0, partials, 0, 1, "vf", 1/30, true);
	pans = OceanodeParameterLag.kr(\panarray, 0.0, partials, 0, 1, "vf", 1/30, true);

	// Width parameter for spatial spread
	width = OceanodeParameter.kr(\width, 2, 1, 0.5, 8, "f", 1/30, true);

	// Levels for each output channel
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Create an array of oscillators with special handling for stereo
	sigArray = Array.fill(partials, { |i|
		var baseFreq = pitch[i];
		var amp = amps[i];
		var sig = SinOsc.ar(baseFreq, Rand(-25, 25), amp);

		if(n == 1) {
			// For mono, no panning needed
			[sig]
		} {
			if(n == 2) {
				// For stereo, use Pan2 which has the behavior we want
				// 0->left, 1->right, 0.5->center
				Pan2.ar(sig, pans[i] * 2 - 1)
			} {
				// For more than 2 channels, use PanAz with orientation 0
				PanAz.ar(n, sig, pans[i] * 2 - 1, 1, width, 0)
			}
		}
	});

	// Mix down to the number of output channels
	mixedSig = Array.fill(n, { |chan|
		Mix.new(sigArray.collect { |sig| sig[chan] });
	});

	// Apply levels after mixing
	mixedSig = mixedSig * levels;

	// Output the final signal with normalized amplitude
	Out.ar(OceanodeOutput.kr(\out), mixedSig / partials);

}, description: "Additive synthesis with 256 sinusoidal oscillators",
   category: "Source/Additive");

// 512 oscillators
~synthCreator.value("Additive512_", {|n|
	var partials = 512;
	var pitch, amps, pans, levels, sigArray, mixedSig, usedpartials, width;

	// Define parameters
	pitch = OceanodeParameter.kr(\pitcharray, 36, partials, 0, 127, "vf").midicps;
	amps = OceanodeParameterLag.kr(\amparray, 0.0, partials, 0, 1, "vf", 1/30, true);
	pans = OceanodeParameterLag.kr(\panarray, 0.0, partials, 0, 1, "vf", 1/30, true);

	// Width parameter for spatial spread
	width = OceanodeParameter.kr(\width, 2, 1, 0.5, 8, "f", 1/30, true);

	// Levels for each output channel
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Create an array of oscillators with special handling for stereo
	sigArray = Array.fill(partials, { |i|
		var baseFreq = pitch[i];
		var amp = amps[i];
		var sig = SinOsc.ar(baseFreq, Rand(-25, 25), amp);

		if(n == 1) {
			// For mono, no panning needed
			[sig]
		} {
			if(n == 2) {
				// For stereo, use Pan2 which has the behavior we want
				// 0->left, 1->right, 0.5->center
				Pan2.ar(sig, pans[i] * 2 - 1)
			} {
				// For more than 2 channels, use PanAz with orientation 0
				PanAz.ar(n, sig, pans[i] * 2 - 1, 1, width, 0)
			}
		}
	});

	// Mix down to the number of output channels
	mixedSig = Array.fill(n, { |chan|
		Mix.new(sigArray.collect { |sig| sig[chan] });
	});

	// Apply levels after mixing
	mixedSig = mixedSig * levels;

	// Output the final signal with normalized amplitude
	Out.ar(OceanodeOutput.kr(\out), mixedSig / partials);

}, description: "Additive synthesis with 512 sinusoidal oscillators",
   category: "Source/Additive");

// 1080 oscillators
~synthCreator.value("Additive1080_", {|n|
	var partials = 1080;
	var pitch, amps, pans, levels, sigArray, mixedSig, usedpartials, width;

	// Define parameters
	pitch = OceanodeParameter.kr(\pitcharray, 36, partials, 0, 127, "vf").midicps;
	amps = OceanodeParameterLag.kr(\amparray, 0.0, partials, 0, 1, "vf", 1/30, true);
	pans = OceanodeParameterLag.kr(\panarray, 0.0, partials, 0, 1, "vf", 1/30, true);

	// Width parameter for spatial spread
	width = OceanodeParameter.kr(\width, 2, 1, 0.5, 8, "f", 1/30, true);

	// Levels for each output channel
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Create an array of oscillators with special handling for stereo
	sigArray = Array.fill(partials, { |i|
		var baseFreq = pitch[i];
		var amp = amps[i];
		var sig = SinOsc.ar(baseFreq, Rand(-25, 25), amp);

		if(n == 1) {
			// For mono, no panning needed
			[sig]
		} {
			if(n == 2) {
				// For stereo, use Pan2 which has the behavior we want
				// 0->left, 1->right, 0.5->center
				Pan2.ar(sig, pans[i] * 2 - 1)
			} {
				// For more than 2 channels, use PanAz with orientation 0
				PanAz.ar(n, sig, pans[i] * 2 - 1, 1, width, 0)
			}
		}
	});

	// Mix down to the number of output channels
	mixedSig = Array.fill(n, { |chan|
		Mix.new(sigArray.collect { |sig| sig[chan] });
	});

	// Apply levels after mixing
	mixedSig = mixedSig * levels;

	// Output the final signal with normalized amplitude
	Out.ar(OceanodeOutput.kr(\out), mixedSig / partials);

}, description: "Additive synthesis with 1080 sinusoidal oscillators",
   category: "Source/Additive");

// 1200 oscillators
~synthCreator.value("Additive1200_", {|n|
	var partials = 1200;
	var pitch, amps, pans, levels, sigArray, mixedSig, usedpartials, width;

	// Define parameters
	pitch = OceanodeParameter.kr(\pitcharray, 36, partials, 0, 127, "vf").midicps;
	amps = OceanodeParameterLag.kr(\amparray, 0.0, partials, 0, 1, "vf", 1/30, true);
	pans = OceanodeParameterLag.kr(\panarray, 0.0, partials, 0, 1, "vf", 1/30, true);

	// Width parameter for spatial spread
	width = OceanodeParameter.kr(\width, 2, 1, 0.5, 8, "f", 1/30, true);

	// Levels for each output channel
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

	// Create an array of oscillators with special handling for stereo
	sigArray = Array.fill(partials, { |i|
		var baseFreq = pitch[i];
		var amp = amps[i];
		var sig = SinOsc.ar(baseFreq, Rand(-25, 25), amp);

		if(n == 1) {
			// For mono, no panning needed
			[sig]
		} {
			if(n == 2) {
				// For stereo, use Pan2 which has the behavior we want
				// 0->left, 1->right, 0.5->center
				Pan2.ar(sig, pans[i] * 2 - 1)
			} {
				// For more than 2 channels, use PanAz with orientation 0
				PanAz.ar(n, sig, pans[i] * 2 - 1, 1, width, 0)
			}
		}
	});

	// Mix down to the number of output channels
	mixedSig = Array.fill(n, { |chan|
		Mix.new(sigArray.collect { |sig| sig[chan] });
	});

	// Apply levels after mixing
	mixedSig = mixedSig * levels;

	// Output the final signal with normalized amplitude
	Out.ar(OceanodeOutput.kr(\out), mixedSig / partials);

}, description: "Additive synthesis with 1200 sinusoidal oscillators",
   category: "Source/Additive");

)