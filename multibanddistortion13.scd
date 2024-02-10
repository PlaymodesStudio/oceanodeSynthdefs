SynthDef(\multibanddistortion13, {
	arg in=0, out=0;
	var highFreq, lowFreq, masterLevel, dryWet, midRq, signals, drySignal, low, mid, high;
	var distortedLow, distortedMid, distortedHigh, mixedSignal, finalSignal;

	// Input signal from the specified bus - expecting 13 channels
	signals = In.ar(in, 13);
	drySignal = signals;

	// Frequency bands
	lowFreq = \lowfreq.kr(300!13);  // Lower crossover frequency
	highFreq = \highfreq.kr(3200!13);  // Higher crossover frequency

	// Splitting the signal into three bands
	low = LPF.ar(LPF.ar(signals, lowFreq), lowFreq);
	signals = signals - low;  // Remove the low frequencies from the original signal to isolate the mids and highs
	mid = LPF.ar(LPF.ar(signals, highFreq), highFreq);
	high = signals - mid;  // What remains after removing mid frequencies are the high frequencies


	// Apply distortion to each band
	distortedLow = low.tanh * \lowdrive.kr(1!13);
	distortedMid = mid.tanh * \middrive.kr(1!13);
	distortedHigh = high.tanh * \highdrive.kr(1!13);

	// Apply gain correction to each band
	distortedLow = distortedLow * \lowgain.kr(1!13);
	distortedMid = distortedMid * \midgain.kr(1!13);
	distortedHigh = distortedHigh * \highgain.kr(1!13);

	// Mix all distorted signals
	mixedSignal = Mix.new([distortedLow, distortedMid, distortedHigh]);

	// Dry/Wet Mix
	dryWet = \drywet.kr(0.5);
	finalSignal = (dryWet * mixedSignal) + ((1 - dryWet) * drySignal);

	// Master Level - control the overall level of the final signal
	masterLevel = \level.kr(1!13);

	// Final signal - applying master amplitude control
	finalSignal = finalSignal * masterLevel;

	// Output
	Out.ar(out, finalSignal);
}).writeDefFile(d);


d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\multibandsineshaper13, {
    arg in=0, out=0;
    var dryWet, lowFreq, highFreq, masterLevel, signals, low, mid, high;
    var shapedLow, shapedMid, shapedHigh, mixedSignal, finalSignal, drySignal;

    // Input signal from the specified bus - expecting 13 channels
    signals = In.ar(in, 13);
	drySignal=signals;

    // Frequency bands
    lowFreq = \lowfreq.kr(300!13);  // Lower crossover frequency
    highFreq = \highfreq.kr(3200!13);  // Higher crossover frequency

    // Splitting the signal into three bands using nested LPF for steeper rolloff
    low = LPF.ar(LPF.ar(signals, lowFreq), lowFreq);
    mid = LPF.ar(LPF.ar(signals - low, highFreq), highFreq);
    high = signals - low - mid;

    // Apply sine shaping distortion to each band with dedicated drive controls
    shapedLow = (low * \lowdrive.kr(1!13)).sin;
    shapedMid = (mid * \middrive.kr(1!13)).sin;
    shapedHigh = (high * \highdrive.kr(1!13)).sin;

	// Apply gain correction to each band
	shapedLow = shapedLow * \lowgain.kr(1!13);
	shapedMid = shapedMid * \midgain.kr(1!13);
	shapedHigh = shapedHigh * \highgain.kr(1!13);

    // Mix all shaped signals
    mixedSignal = Mix.new([shapedLow, shapedMid, shapedHigh]);

    // Dry/Wet Mix
    dryWet = \drywet.kr(0.5);
	finalSignal = (dryWet * mixedSignal) + ((1 - dryWet) * drySignal);

    // Master Level - control the overall level of the final signal
    masterLevel = \level.kr(1!13);

    // Final signal - applying master amplitude control
    finalSignal = finalSignal * masterLevel;

    // Output
    Out.ar(out, finalSignal);
}).writeDefFile(d);
)

