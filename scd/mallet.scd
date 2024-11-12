/*
(
SynthDef(\mallet, {
	arg out=0;
	var exciter, sig, finalSig;

	// Pitch for multiple voices - expecting 78 pitches
	var p = \pitch.kr(80!78).midicps;

	// T60 (decay time) for multiple voices - expecting 78 values
	var t60 = \t60.kr(2.5!78);

	// Amplitude for multiple voices - expecting 78 amplitudes
	var amp = \amp.kr(0.25!78);

	// External trigger for multiple voices - expecting 78 triggers
	var gate = \gate.kr(1!78);

	// Pan position for multiple voices - expecting 78 positions
	var pan = \pan.kr(0!78);

	// Exciter - White noise burst shaped by an envelope
	exciter = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), gate) * 0.25;

	// Synthesis - Modal resonances using DynKlank
	sig = DynKlank.ar(
		`[
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // freqs
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]*t60  // ring times
		],
		exciter,
		freqscale: p
	);

	// Final signal - applying amplitude control
	finalSig = sig * amp;

	// Output - 78 channels
	Out.ar(out, finalSig);
}).writeDefFile(d);
)
*/

(
SynthDef(\mallet, {
    arg out = 0;
    // Named controls with multichannel expansion (78 channels)
    var pitch = \pitch.kr(80!78).midicps;
    var t60 = \t60.kr(2.5!78);
    var amp = \amp.kr(0.25!78);
    var gate = \gate.kr(0!78);
    var snd;

    // Generate sound for each channel
    snd = Array.fill(78, {|i|
        var exciter, sig;

        // Exciter - using the original envelope design
        exciter = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), gate[i]) * 0.25;

        // Synthesis using DynKlank
        sig = DynKlank.ar(
            `[
                [1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],
                [1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079],
                [1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047] * t60[i]
            ],
            exciter,
            freqscale: pitch[i]
        );

        // Apply amplitude
        sig * amp[i]
    });

    // Output each channel separately
    Out.ar(out, snd);
}).writeDefFile(d);
)

(
SynthDef(\mallet13, {
    arg out = 0;
	var nch=13;
    // Named controls with multichannel expansion
    var pitch = \pitch.kr(80!nch).midicps;
    var t60 = \t60.kr(2.5!nch);
    var amp = \amp.kr(0.25!nch);
    var gate = \gate.kr(0!nch);
    var snd;

    // Generate sound for each channel
    snd = Array.fill(nch, {|i|
        var exciter, sig;

        // Exciter - using the original envelope design
        exciter = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), gate[i]) * 0.25;

        // Synthesis using DynKlank
        sig = DynKlank.ar(
            `[
                [1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],
                [1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079],
                [1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047] * t60[i]
            ],
            exciter,
            freqscale: pitch[i]
        );

        // Apply amplitude
        sig * amp[i]
    });

    // Output each channel separately
    Out.ar(out, snd);
}).writeDefFile(d);
)

(
SynthDef(\malletdrone13, {
    arg out = 0;
	var nch=13;
    // Named controls with multichannel expansion
    var pitch = \pitch.kr(80!nch).midicps;
    var t60 = \t60.kr(2.5!nch);
    var amp = \amp.kr(0.25!nch);
    var excite = \excite.kr(0.2!nch);
    var snd;

    // Generate sound for each channel
    snd = Array.fill(nch, {|i|
        var exciter, sig;

        // Exciter - using the original envelope design
        exciter = WhiteNoise.ar() * 0.25 * excite;

        // Synthesis using DynKlank
        sig = DynKlank.ar(
            `[
                [1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],
                [1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079],
                [1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047] * t60[i]
            ],
            exciter,
            freqscale: pitch[i]
        );

        // Apply amplitude
        sig * amp[i]
    });

    // Output each channel separately
	Out.ar(out, Limiter.ar(snd*0.1));
}).writeDefFile(d);
)

(
SynthDef(\malletin13, {
    arg out, in;
	var nch=13;
    // Named controls with multichannel expansion
    var pitch = \pitch.kr(80!nch).midicps;
    var t60 = \t60.kr(2.5!nch);
    var amp = \amp.kr(0.25!nch);
    var snd;
	var inp=In.ar(in,nch);

    // Generate sound for each channel
    snd = Array.fill(nch, {|i|
        var exciter, sig;

        // Exciter - using the original envelope design
		exciter = inp[i] * 0.1;

        // Synthesis using DynKlank
        sig = DynKlank.ar(
            `[
                [1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],
                [1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079],
                [1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047] * t60[i]
            ],
            exciter,
            freqscale: pitch[i]
        );

        // Apply amplitude
        sig * amp[i]
    });

    // Output each channel separately
	Out.ar(out, Limiter.ar(snd*0.1));
}).writeDefFile(d);
)
d = thisProcess.nowExecutingPath.dirname;
