(
SynthDef(\verb13, {
	arg out=0, in=0;
	var decay=\decay.kr(3), feedback=\feed.kr(0.9);
	var sig, fbk;
	var numChans=13;
	sig = In.ar(in, numChans);
	sig = OnePole.ar(sig, 0.72);
	sig = AllpassC.ar(sig, 0.3, LFNoise1.kr(1).range(0.3,0.29), 3);
	fbk = LocalIn.ar(numChans);
	(numChans > 1).if({ fbk = fbk.scramble });
	fbk = OnePole.ar(fbk, 0.2);
	fbk = fbk + sig;
	7.do { fbk = AllpassN.ar(fbk, 0.05, {0.050.rand}!numChans, decay) };
	LocalOut.ar(fbk * feedback);
	Out.ar(out, fbk);
}).add;
)

(
SynthDef(\freeverb13, {
    arg in = 0, out = 0;
	var mix = \mix.kr(0.33), room = \room.kr(0.5), damp = \hfdamp.kr(0.5),
	predelay = \predelay.kr(0.1), lfdamp = \lfdamp.kr(0.5), amp = 1;
    var sig, wet, dry, predelayed;
	var numchans=13;

    // Input signal (assuming stereo, but can be multichannel)
    sig = In.ar(in, numchans);

    // Predelay
    predelayed = DelayN.ar(sig, 1, predelay);

    // FreeVerb processing
    wet = FreeVerb.ar(predelayed, 1, room, damp);

    // LF damping using a low-shelf filter
    wet = BLowShelf.ar(wet, 300, 1, lfdamp * -6);

    // Mix dry and wet signals
    dry = sig * (1 - mix);
    wet = wet * mix;

    // Output
    Out.ar(out, (dry + wet));
}).add;
)