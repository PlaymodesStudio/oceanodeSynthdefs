d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\supersaw13, {
	arg out=0;
	// Parameters with multichannel expansion
	var freq = \pitch.kr(36 ! 13),
	    mix = \mix.kr(0.75 ! 13),
	    detune = \detune.kr(0.75 ! 13),
	levels = \levels.kr(1!13),
	trem,vib;

	var detuneCurve, centerGain, sideGain, signals;

	trem=1-((SinOsc.ar(\tremf.kr(0!13),0,1,1)/2)*\trema.kr(0!13));
	vib=SinOsc.ar(\vibf.kr(0!13),0,\viba.kr(0!13),0);
	freq=(freq+vib).midicps;

	// Detune curve function
	detuneCurve = { |x|
		(10028.7312891634*x.pow(11)) -
		(50818.8652045924*x.pow(10)) +
		(111363.4808729368*x.pow(9)) -
		(138150.6761080548*x.pow(8)) +
		(106649.6679158292*x.pow(7)) -
		(53046.9642751875*x.pow(6)) +
		(17019.9518580080*x.pow(5)) -
		(3425.0836591318*x.pow(4)) +
		(404.2703938388*x.pow(3)) -
		(24.1878824391*x.pow(2)) +
		(0.6717417634*x) +
		0.0030115596
	};

	// Gain functions
	centerGain = { |x| (-0.55366 * x) + 0.99785 };
	sideGain = { |x| (-0.73764 * x.pow(2)) + (1.2841 * x) + 0.044372 };

	// Generate signals for each voice
	signals = Array.fill(13, { |i|
		var thisFreq = freq[i];
		var thisMix = mix[i];
		var thisDetune = detune[i];
		var detuneFactor = thisFreq * detuneCurve.(thisDetune);
		var center = LFSaw.ar(thisFreq, 0); // Central oscillator
		var freqs = [ // Frequencies for detuned oscillators
			(thisFreq - (detuneFactor * 0.11002313)),
			(thisFreq - (detuneFactor * 0.06288439)),
			(thisFreq - (detuneFactor * 0.01952356)),
			(thisFreq + (detuneFactor * 0.01991221)),
			(thisFreq + (detuneFactor * 0.06216538)),
			(thisFreq + (detuneFactor * 0.10745242))
		];
		var side = Mix.fill(6, { |n|
			LFSaw.ar(freqs[n], Rand(0,2))
		});
		var sig = (center * centerGain.(thisMix)) + (side * sideGain.(thisMix));
		HPF.ar(sig, thisFreq) // Apply high-pass filter
	});
	signals=signals*levels*trem;

	// Route each signal to its respective output channel
	Out.ar(out, signals);
}).writeDefFile(d);
)

(
SynthDef(\supersaw6, {
	arg out=0;
	// Parameters with multichannel expansion
	var freq = \pitch.kr(36 ! 6).midicps,
	    mix = \mix.kr(0.75 ! 6),
	    detune = \detune.kr(0.75 ! 6),
	levels = \levels.kr(1!6);

	var detuneCurve, centerGain, sideGain, signals;

	// Detune curve function
	detuneCurve = { |x|
		(10028.7312891634*x.pow(11)) -
		(50818.8652045924*x.pow(10)) +
		(111363.4808729368*x.pow(9)) -
		(138150.6761080548*x.pow(8)) +
		(106649.6679158292*x.pow(7)) -
		(53046.9642751875*x.pow(6)) +
		(17019.9518580080*x.pow(5)) -
		(3425.0836591318*x.pow(4)) +
		(404.2703938388*x.pow(3)) -
		(24.1878824391*x.pow(2)) +
		(0.6717417634*x) +
		0.0030115596
	};

	// Gain functions
	centerGain = { |x| (-0.55366 * x) + 0.99785 };
	sideGain = { |x| (-0.73764 * x.pow(2)) + (1.2841 * x) + 0.044372 };

	// Generate signals for each voice
	signals = Array.fill(6, { |i|
		var thisFreq = freq[i];
		var thisMix = mix[i];
		var thisDetune = detune[i];
		var detuneFactor = thisFreq * detuneCurve.(thisDetune);
		var center = LFSaw.ar(thisFreq, 0); // Central oscillator
		var freqs = [ // Frequencies for detuned oscillators
			(thisFreq - (detuneFactor * 0.11002313)),
			(thisFreq - (detuneFactor * 0.06288439)),
			(thisFreq - (detuneFactor * 0.01952356)),
			(thisFreq + (detuneFactor * 0.01991221)),
			(thisFreq + (detuneFactor * 0.06216538)),
			(thisFreq + (detuneFactor * 0.10745242))
		];
		var side = Mix.fill(6, { |n|
			LFSaw.ar(freqs[n], Rand(0,2))
		});
		var sig = (center * centerGain.(thisMix)) + (side * sideGain.(thisMix));
		HPF.ar(sig, thisFreq) // Apply high-pass filter
	});
	signals=signals*levels;

	// Route each signal to its respective output channel
	Out.ar(out, signals);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\superpulse13, {
	arg out=0;
	// Parameters with multichannel expansion
	var freq = \pitch.kr(36 ! 13).midicps,
	    mix = \mix.kr(0.75 ! 13),
	    detune = \detune.kr(0.75 ! 13),
	pw = \pw.kr(0.5 ! 13),
	levels = \levels.kr(1!13);

	var detuneCurve, centerGain, sideGain, signals;

	// Detune curve function
	detuneCurve = { |x|
		(10028.7312891634*x.pow(11)) -
		(50818.8652045924*x.pow(10)) +
		(111363.4808729368*x.pow(9)) -
		(138150.6761080548*x.pow(8)) +
		(106649.6679158292*x.pow(7)) -
		(53046.9642751875*x.pow(6)) +
		(17019.9518580080*x.pow(5)) -
		(3425.0836591318*x.pow(4)) +
		(404.2703938388*x.pow(3)) -
		(24.1878824391*x.pow(2)) +
		(0.6717417634*x) +
		0.0030115596
	};

	// Gain functions
	centerGain = { |x| (-0.55366 * x) + 0.99785 };
	sideGain = { |x| (-0.73764 * x.pow(2)) + (1.2841 * x) + 0.044372 };

	// Generate signals for each voice
	signals = Array.fill(13, { |i|
		var thisFreq = freq[i];
		var thisMix = mix[i];
		var thisDetune = detune[i];
		var detuneFactor = thisFreq * detuneCurve.(thisDetune);
		var center = LFPulse.ar(thisFreq, 0,pw); // Central oscillator
		var freqs = [ // Frequencies for detuned oscillators
			(thisFreq - (detuneFactor * 0.11002313)),
			(thisFreq - (detuneFactor * 0.06288439)),
			(thisFreq - (detuneFactor * 0.01952356)),
			(thisFreq + (detuneFactor * 0.01991221)),
			(thisFreq + (detuneFactor * 0.06216538)),
			(thisFreq + (detuneFactor * 0.10745242))
		];
		var side = Mix.fill(6, { |n|
			LFPulse.ar(freqs[n], Rand(0,2),pw)
		});
		var sig = (center * centerGain.(thisMix)) + (side * sideGain.(thisMix));
		HPF.ar(sig, thisFreq) // Apply high-pass filter
	});
	signals=signals*levels;

	// Route each signal to its respective output channel
	Out.ar(out, signals);
}).writeDefFile(d);
)