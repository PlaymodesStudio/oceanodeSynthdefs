(
File.mkdir(d ++ "/" ++ "beatTracker");

(1..~maxVoices).do({ arg n;
	var numChan = n;
	SynthDef.new(\beatTracker ++ numChan.asSymbol, {
		arg in, quarter, eighth, sixteenth, tempo;
		var input, fft, q, e, s, bpm;
		var qPulse, ePulse, sPulse;

		input = Mix(In.ar(in, numChan));
		fft = FFT(LocalBuf(1024), input);

		#q, e, s, bpm = BeatTrack.kr(fft, 0);

		// Hold triggers long enough to be read
		qPulse = Decay.kr(q, 0.1);  // ~100ms visibility
		ePulse = Decay.kr(e, 0.1);
		sPulse = Decay.kr(s, 0.1);

		Out.kr(quarter, qPulse);
		Out.kr(eighth, ePulse);
		Out.kr(sixteenth, sPulse);
		Out.kr(tempo, bpm * 60);  // Convert Hz → BPM
	}).writeDefFile(d ++ "/beatTracker");
});
)