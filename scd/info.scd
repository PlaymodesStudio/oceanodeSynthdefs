
d = thisProcess.nowExecutingPath.dirname;



(
SynthDef.new(\info2, {
	arg in, amp, peak, lagTime = 0.2, decay = 0.99;
	var sig;
	sig = In.ar(in, 2);
	//SendReply.kr(Impulse.kr(3), '/amp', [40, 41, 42, 43], 2);
	//SendReply.kr(Impulse.kr(3), \peak, PeakFollower.kr(sig));
	Out.kr(amp, Lag.kr(Amplitude.kr(sig), lagTime));
	Out.kr(peak, PeakFollower.kr(sig, decay));
}).writeDefFile(d);
)

(
SynthDef.new(\info6, {
	arg in, amp, peak, lagTime = 0.2, decay = 0.99;
	var sig;
	sig = In.ar(in, 6);
	//SendReply.kr(Impulse.kr(3), '/amp', [40, 41, 42, 43], 2);
	//SendReply.kr(Impulse.kr(3), \peak, PeakFollower.kr(sig));
	Out.kr(amp, Lag.kr(Amplitude.kr(sig), lagTime));
	Out.kr(peak, PeakFollower.kr(sig, decay));
}).writeDefFile(d);
)


(
SynthDef.new(\info13, {
	arg in, amp, peak, lagTime = 0.2, decay = 0.99;
	var sig;
	sig = In.ar(in, 13);
	//SendReply.kr(Impulse.kr(3), '/amp', [40, 41, 42, 43], 2);
	//SendReply.kr(Impulse.kr(3), \peak, PeakFollower.kr(sig));
	Out.kr(amp, Lag.kr(Amplitude.kr(sig), lagTime));
	Out.kr(peak, PeakFollower.kr(sig, decay));
}).writeDefFile(d);
)


(
SynthDef.new(\info78, {
	arg in, amp, peak, lagTime = 0.2, decay = 0.99;
	var sig;
	sig = In.ar(in, 78);
	//SendReply.kr(Impulse.kr(3), '/amp', [40, 41, 42, 43], 2);
	//SendReply.kr(Impulse.kr(3), \peak, PeakFollower.kr(sig));
	Out.kr(amp, Lag.kr(Amplitude.kr(sig), lagTime));
	Out.kr(peak, PeakFollower.kr(sig, decay));
}).writeDefFile(d);
)