(
~synthCreator.value("SchroederReverb", {|n|
	var input, output, wet, dry, temp, signal;
	var preDelay, allpassTimes, combTimes;

	// Main reverb parameters
	var decay = OceanodeParameterLag.ar(\decay, 0.6, n, 0, 12, "vf", 0.05, true);
	var diffusion = OceanodeParameterLag.ar(\diffusion, 0.07, n, 0, 1, "vf", 0.05, true);
	var loPass = OceanodeParameterLag.ar(\lopass, 130, n, 0, 130, "vf", 0.05, true); // Note: 130 midi is ~12kHz
	var hiPass = OceanodeParameterLag.ar(\hipass, 12, n, 0, 130, "vf", 0.05, true);  // Note: 12 midi is ~70Hz

	// Blend parameters for spatial variation
	var blendOffset = OceanodeParameterLag.ar(\blendoff, 0.1, n, 0, 1, "vf", 0.05, true);
	var blendScale = OceanodeParameterLag.ar(\blendscale, 0.9, n, 0, 3, "vf", 0.05, true);

	// Wet/dry mix
	var mix = OceanodeParameterLag.ar(\mix, 0.33, n, 0, 1, "vf", 0.05, true);

	// Input from the specified bus
	input = In.ar(OceanodeInput.kr(\in), n);

	// Parameter definitions with proper ranges
	preDelay = OceanodeParameterLag.ar(\predelay, 0.001, n, 0, 1, "vf", 0.05, true);

	// Create dry signal path
	dry = input;

	// Pre-delay the wet signal
	wet = DelayN.ar(input, 1, preDelay);

	// First diffusion stage - multiple allpass filters in series
	allpassTimes = Array.fill(4, { arg i;
		// Slightly different delay times for each channel
		(0.005 + 0.0013 * i) * (LFNoise1.kr(0.1 ! n).range(blendOffset, blendOffset + blendScale));
	});

	4.do({ arg i;
		wet = AllpassC.ar(wet, 0.1, allpassTimes[i], decay * 0.5);
	});

	// Second diffusion stage - parallel comb filters
	combTimes = Array.fill(7, { arg i;
		// Distributed delay times
		(0.02 + 0.0013 * i) * (LFNoise1.kr(0.1 ! n).range(blendOffset, blendOffset + blendScale));
	});

	temp = 0;
	combTimes.do({ arg time;
		temp = temp + CombC.ar(wet, 0.2, time, decay);
	});
	wet = temp / combTimes.size;

	// Final diffusion stage - more allpass filters
	4.do({ arg i;
		wet = AllpassC.ar(wet, 0.1,
			0.05 * (LFNoise1.kr(0.1 ! n).range(blendOffset, blendOffset + blendScale)),
			decay * 0.5);
	});

	// Apply filtering
	wet = LPF.ar(wet, loPass.midicps);
	wet = HPF.ar(wet, hiPass.midicps);

	// DC blocking and normalization
	wet = LeakDC.ar(wet);
	wet = wet * 0.2; // Level adjustment

	// Mix dry and wet signals
	signal = (dry * (1-mix)) + (wet * mix);

	// Output to specified bus
	Out.ar(OceanodeOutput.kr(\out), signal);

}, description: "Schroeder feedback network reverb algorithm with diffusion control", category: "Effect/Time/Reverb");
)