(
~synthCreator.value("Vectory", {|n, variables|
	var buf, gain, duration, trigger, signal;
	var bufFrames, sliceSize;
	var phaseIndex, currentStep, stepPhase;
	var pattern, pitchValues, releaseValues, volumeValues, reverseValues, grainpitchValues, filterValues;
	var numSlices, numSteps, maxSlices, maxSteps;
	var sliceIndex, sliceStart, pitch, release, volume, reverse, grainpitch, filter, mode;
	var loopCount, loopPhase, readPos;
	var windowSize, pitchRatio;
	var minFreq, maxFreq, lpFreq, hpFreq;
	var normalRate, slicePlaybackPhase, sampleRateCorrection;

	// Maximum value for divisions (slices/steps)
	maxSlices = 32;
	maxSteps = maxSlices; // Keep consistent with maxSlices

	// Define our parameters
	buf = OceanodeBuffer.kr(\bufnum);
	gain = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	duration = OceanodeParameterLag.ar(\duration, 2000, n, 100, 16000, "vf", 0.05, true)/1000.0;
	trigger = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");
	mode = OceanodeParameter.kr(\mode, 0, n, 0, 1, "vi");

	// Division parameters
	numSlices = OceanodeParameter.kr(\numsteps, 8, n, 2, maxSlices, "vi");
	numSteps = numSlices;

	// Pattern parameter - which slice to play at each step
	pattern = OceanodeParameter.ar(\pattern, 0, maxSteps, 0, maxSlices-1, "vi");

	// Per-step effect parameters
	pitchValues = OceanodeParameter.ar(\pitch, 0, maxSteps, -24, 24, "vf");
	releaseValues = OceanodeParameter.ar(\rel, 1, maxSteps, 0, 1, "vf");
	volumeValues = OceanodeParameter.ar(\amp, 1, maxSteps, 0, 1, "vf");
	reverseValues = OceanodeParameter.ar(\reverse, 0, maxSteps, 0, 1, "vi");
	grainpitchValues = OceanodeParameter.ar(\grainpitch, 0, maxSteps, -24, 24, "vf");
	filterValues = OceanodeParameter.ar(\filter, 0, maxSteps, -1, 1, "vf"); // Range -1 to 1

	// Sample rate correction
	sampleRateCorrection = BufSampleRate.kr(buf) / SampleRate.ir;

	// Calculate buffer properties
	bufFrames = BufFrames.kr(buf);
	sliceSize = bufFrames / numSlices.max(1); // Divide buffer into equal slices

	// Create a phasor for the overall sequence
	phaseIndex = Phasor.ar(
		trigger,
		numSteps / (duration * BufSampleRate.kr(buf)) * sampleRateCorrection, // Rate to complete sequence in 'duration' seconds
		0,
		numSteps
	);

	// Get the current step and phase within step
	currentStep = phaseIndex.floor.clip(0, numSteps - 1);
	stepPhase = phaseIndex - currentStep; // Phase within step (0-1)

	// Use audio rate Select for parameters
	sliceIndex = Select.ar(currentStep, pattern);
	pitch = Select.ar(currentStep, pitchValues);
	release = Select.ar(currentStep, releaseValues);
	volume = Select.ar(currentStep, volumeValues);
	reverse = Select.ar(currentStep, reverseValues);
	grainpitch = Select.ar(currentStep, grainpitchValues);
	filter = LPF.ar(Select.ar(currentStep, filterValues), 36.midicps); // With declicking LPF

	// Convert pitch from semitones to ratio for time-stretching
	pitchRatio = 2.pow(pitch/12).max(0.25);

	// Calculate slice position
	sliceStart = sliceIndex * sliceSize;

	// Define normal rate as the rate to play through a slice at regular speed
	normalRate = BufSampleRate.kr(buf) / sliceSize; // Playback rate that covers the slice in 1 second

	// Create a trigger signal that pulses at the start of each step
	// This resets our slice playback phasor
	slicePlaybackPhase = Phasor.ar(
		// Reset phasor when step changes
		Trig1.ar(HPZ1.ar(currentStep), SampleDur.ir),
		// Progress at normalRate * pitchRatio
		normalRate * pitchRatio / BufSampleRate.kr(buf) * sampleRateCorrection,
		0,
		1
	);

	// Use different phasing depending on mode
	loopPhase = Select.ar(
		mode,
		[
			// Mode 0: Original loopPhase calculation (duration affects playback speed)
			(stepPhase * pitchRatio) - (stepPhase * pitchRatio).floor,

			// Mode 1: Direct slice playback at normal rate (duration independent)
			slicePlaybackPhase - slicePlaybackPhase.floor
		]
	);

	// Select between forward and reverse reading based on the reverse parameter
	readPos = Select.ar(
		(reverse > 0.5), [
			// Forward reading (normal direction)
			sliceStart + (loopPhase * sliceSize),
			// Reverse reading
			sliceStart + ((1 - loopPhase) * sliceSize)
		]
	);

	// Read from buffer with interpolation
	signal = BufRd.ar(n, buf, readPos, 1, 2);

	// Apply release envelope
	signal = signal * (1 - ((1-release) * (loopPhase > release)));

	// Apply pitch shifting
	signal = PitchShift.ar(
		signal,
		0.1,     // Window size
		2.pow(grainpitch/12), // Pitch ratio (semitone conversion)
		0,              // No pitch dispersion
		0               // No time dispersion
	);

	// Simple filter implementation
	minFreq = 20;
	maxFreq = 20000;

	// For negative filter values (LP): -1 to 0 maps to 20Hz to 20kHz
	lpFreq = (1 - (filter * -1).clip(0, 1)).linexp(0, 1, minFreq, maxFreq);

	// For positive filter values (HP): 0 to 1 maps to 20Hz to 20kHz
	hpFreq = filter.clip(0, 1).linexp(0, 1, minFreq, maxFreq);

	// Apply the filters
	signal = LPF.ar(signal, lpFreq);
	signal = HPF.ar(signal, hpFreq);

	// Apply volume
	signal = signal * volume;

	// Apply gain and output
	signal = signal * gain;
	Out.ar(OceanodeOutput.kr(\out), signal);

}, description: "Breakbeat sequencer with pitch shifting and filtering per step", category: "Source/Sampler");
)