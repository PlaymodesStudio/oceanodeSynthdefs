(
File.mkdir(d ++ "/" ++ "info");
(1..~maxVoices).do({arg n;
	var numChan = n;
	SynthDef.new(\info ++ (numChan).asSymbol, {
		arg in, amp, peak, value, lagTime = 0.2, decay = 0.99;
		var sig;
		sig = In.ar(in, numChan);
		Out.kr(amp, Lag.kr(Amplitude.kr(sig), lagTime));
		Out.kr(peak, PeakFollower.kr(sig, decay));
		Out.kr(value, A2K.kr(sig));
	}).writeDefFile(d ++ "/info");
})
)