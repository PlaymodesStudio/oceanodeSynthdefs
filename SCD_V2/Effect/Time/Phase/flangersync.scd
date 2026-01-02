(
~synthCreator.value("FlangerSync", {|n|
	var source, wet, sig, numchans, rate, minDelay, maxDelay, decayTime, mx, send;
	var lfoA, lfoB, combA, combB;
	
	// All variables must be declared at the beginning
	numchans = n;
	
	// Parameters with appropriate ranges
	rate = OceanodeParameter.ar(\rate, 0.01, n, 0, 1, "vf");
	minDelay = OceanodeParameter.ar(\mindel, 0.004, n, 0, 0.1, "vf");
	maxDelay = OceanodeParameter.ar(\maxdel, 0.01, n, 0, 0.1, "vf");
	decayTime = OceanodeParameter.ar(\decay, 1, n, 0, 2, "vf");
	mx = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);
	
	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply send amount
	source = source * send;
	
	// Create flanger effect with synchronized LFOs
	lfoA = LFSaw.ar(rate, 1, (maxDelay * 0.5) - minDelay, (maxDelay * 0.5) + minDelay); // initial phase of 0 radians
	lfoB = LFSaw.ar(rate, 0, (maxDelay * 0.5) - minDelay, (maxDelay * 0.5) + minDelay); // initial phase of pi radians
	
	combA = CombC.ar(source, maxDelay, lfoA, decayTime);
	combB = CombC.ar(source, maxDelay, lfoB, decayTime);
	
	wet = XFade2.ar(combA, combB, LFTri.kr(rate, 1)); // crossfade between the two combs
	
	// Mix dry and wet signals using XFade2
	sig = XFade2.ar(In.ar(OceanodeInput.kr(\in), n), wet, mx * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Synchronized flanger effect with dual LFOs", category: "Effect/Time/Phase");
)