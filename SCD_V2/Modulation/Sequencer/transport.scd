(
~synthCreator.value("Transport", {|n|
	// Basic variables
	var play, reset, loop, bpm;
	var inPoint, outPoint;
	var timeSignatureNumerator, timeSignatureDenominator;

	// Internal calculation variables
	var isPlaying, playTrig, stopTrig, resetTrig;
	var sampleRate, ticksPerSample;
	var barDuration, inPointTicks, outPointTicks;
	var counter, counterWrapped, positionHolder;
	var barCounter, beatCounter, sixteenthCounter, tickCounter, msCounter;
	var ticksInBar, ticksPerBeat, ticksPerSixteenth;
	var beatWeight, beatPatterns;

	// Input parameters with proper types
	bpm = OceanodeParameterLag.kr(\bpm, 120, n, 20, 300, "f", 0.1);
	play = OceanodeParameter.kr(\play, 0, n, 0, 1, "i").clip(0, 1);
	reset = OceanodeParameter.kr(\reset, 0, n, 0, 1, "i").clip(0, 1);
	loop = OceanodeParameter.kr(\loop, 1, n, 0, 1, "i").clip(0, 1);
	inPoint = OceanodeParameterLag.kr(\inpoint, 0, n, 0, 100, "f", 0.05);
	outPoint = OceanodeParameterLag.kr(\outpoint, 4, n, 1, 100, "f", 0.05);
	timeSignatureNumerator = OceanodeParameter.kr(\time_num, 4, n, 1, 32, "i");
	timeSignatureDenominator = OceanodeParameter.kr(\time_den, 4, n, 1, 16, "i");

	// Create clean triggers
	playTrig = Trig.kr(play, 0.01);
	stopTrig = Trig.kr(1-play, 0.01);
	resetTrig = Trig.kr(reset, 0.01);

	// Play state using Set/Reset Flip-Flop
	isPlaying = SetResetFF.kr(playTrig, stopTrig);

	// Basic timing constants
	sampleRate = SampleRate.ir;

	// CRITICAL: Fix the ticks per sample calculation
	// At 120 BPM, a quarter note is 0.5 seconds
	// In 4/4 time, a bar has 4 quarter notes, so a bar is 2 seconds at 120 BPM
	// 96 PPQ means 96 ticks per quarter note
	// For a bar: 4 quarter notes * 96 ticks = 384 ticks per bar
	// At 120 BPM, 384 ticks should take 2 seconds, so 192 ticks per second
	// Ticks per sample = ticks per second / sample rate
	ticksPerSample = (bpm * 96 / 60) / sampleRate;

	// Calculate a bar duration in ticks based on time signature
	// For 4/4, a bar is 4 quarter notes = 4 * 96 = 384 ticks
	barDuration = (timeSignatureNumerator * 96 * 4) / timeSignatureDenominator;

	// Convert bar positions to tick positions
	inPointTicks = inPoint * barDuration;
	outPointTicks = (outPoint * barDuration).max(inPointTicks + barDuration); // Ensure minimum size

	// The main counter that advances at the rate of ticksPerSample when playing
	counter = Phasor.ar(
		trig: resetTrig,
		rate: ticksPerSample * K2A.ar(isPlaying),
		start: K2A.ar(inPointTicks),
		end: K2A.ar(1000000), // Large enough to avoid automatic wrapping
		resetPos: K2A.ar(inPointTicks)
	);

	// Apply looping manually if enabled
	counterWrapped = counter;
	counterWrapped = Select.ar(
		(counter >= outPointTicks) * (loop > 0),
		[
			counter, // Not looping or not at end yet
			((counter - outPointTicks) % (outPointTicks - inPointTicks)) + inPointTicks // Loop back to inPoint
		]
	);

	// Position holder when stopped
	positionHolder = Latch.ar(counterWrapped, K2A.ar(stopTrig));
	counterWrapped = Select.ar(K2A.ar(isPlaying), [positionHolder, counterWrapped]);

	// Calculate position values
	msCounter = counterWrapped * (60000 / (bpm * 96)); // Convert ticks to milliseconds

	// Calculate musical positions
	barCounter = (counterWrapped / barDuration).floor;

	// Get the position within the current bar
	ticksInBar = counterWrapped % barDuration;

	// Calculate beat position (within the current bar)
	ticksPerBeat = barDuration / timeSignatureNumerator;
	beatCounter = (ticksInBar / ticksPerBeat).floor;

	// Calculate beat weight - determine how strong each beat is
	// Define accent patterns for common time signatures
	beatPatterns = [
		[1.0, 0.2, 0.6, 0.2], // 4/4 or 4/2 - Accents on 1 and 3
		[1.0, 0.2, 0.2],      // 3/4 or 3/8 - Accent on 1
		[1.0, 0.2, 0.2, 0.6, 0.2, 0.2], // 6/8 or 6/4 - Accents on 1 and 4
		[1.0, 0.2],           // 2/4 or 2/2 - Accent on 1
		[1.0, 0.4, 0.7, 0.4, 0.7]  // 5/4 or 5/8 - Accents on 1 and 3
	];

	// Select the appropriate pattern based on number of beats in the bar
	// and index into it with the current beat
	beatWeight = Select.kr(
		// Choose pattern based on timeSignatureNumerator
		Select.kr(
			timeSignatureNumerator.clip(2, 6) - 2, // Map 2->0, 3->1, 4->2, 5->3, 6->4
			[1, 1, 0, 4, 2] // Pattern indices for common numerators
		),
		// Index into the selected pattern with current beat
		[
			Select.kr(beatCounter.clip(0, 3), beatPatterns[0]),  // 4 beat pattern (4/4)
			Select.kr(beatCounter.clip(0, 2), beatPatterns[1]),  // 3 beat pattern (3/4)
			Select.kr(beatCounter.clip(0, 5), beatPatterns[2]),  // 6 beat pattern (6/8)
			Select.kr(beatCounter.clip(0, 1), beatPatterns[3]),  // 2 beat pattern (2/4)
			Select.kr(beatCounter.clip(0, 4), beatPatterns[4])   // 5 beat pattern (5/4)
		]
	);

	// Calculate sixteenth note position (within the current beat)
	ticksPerSixteenth = ticksPerBeat / 4; // Assuming 4 sixteenths per beat
	sixteenthCounter = ((ticksInBar % ticksPerBeat) / ticksPerSixteenth).floor;

	// Calculate tick position (within the current sixteenth)
	tickCounter = (ticksInBar % ticksPerSixteenth).floor;

	// Output all values
	Out.ar(OceanodeOutput.kr(\ppqout), counterWrapped);
	Out.ar(OceanodeOutput.kr(\msout), msCounter);
	Out.ar(OceanodeOutput.kr(\barsout), barCounter);
	Out.ar(OceanodeOutput.kr(\beatsout), beatCounter);
	Out.ar(OceanodeOutput.kr(\sixteenthsout), sixteenthCounter);
	Out.ar(OceanodeOutput.kr(\ticksout), tickCounter);
	Out.ar(OceanodeOutput.kr(\beatweight), K2A.ar(beatWeight));

}, description: "Global transport with audio rate timing - Outputs PPQ counter beats bars sixteenths ticks milliseconds and beat weight", category: "Modulation/Sequencer");
)