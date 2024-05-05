(//Panner 6chan
SynthDef.new(\panaz6, {
	arg in, out=0;
	var sig, pos=1,wdth=2;
	pos=\position.ar(0); //range -1 to 1
	wdth=\width.kr(2!6,  1/30, fixedLag: true);
	sig = In.ar(in, 1);
	sig=PanAz.ar(6,sig,pos,1,wdth);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef.new(\panaz13, {
	arg in=0, out=0;
	var monosig, pannedSig, pos, wdth;

	pos = \position.kr(0!13,  1/30, fixedLag: true);  // Expanded control-rate position
	wdth = \width.kr(2!13,  1/30, fixedLag: true);    // Expanded control-rate width

	monosig = In.ar(in, 1);

	// Pan each channel independently using the expanded control signals

	pannedSig=PanAz.ar(13, monosig, pos, 1, wdth);


	// Output the independently panned signals
	Out.ar(out, pannedSig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef.new(\panaz13multi, {
    arg in=0, out=0;
    var signals, pannedSignals, summedSignals, positions, wdth;

    positions = \position.kr(0!13, 1/30, fixedLag:true);
    wdth = \width.kr(2!13, 1/30, fixedLag:true);

    signals = In.ar(in, 13);

    // Pan each channel independently
    pannedSignals = Array.fill(13, { |i|
		PanAz.ar(13, signals[i], positions[i], 1, wdth[i])
    });

    // Sum the signals channel-wise
    summedSignals = Array.fill(13, { |chan|
        pannedSignals.collect({ |sig|
            sig[chan]
        }).sum;
    });

    Out.ar(out, summedSignals);
}).writeDefFile(d);
)

(
SynthDef.new(\panaz78to6, {
    arg in=0, out=0;
    var signals, pannedSignals, summedSignals, positions, wdth;

    // Read 78 channels from the input
    signals = In.ar(in, 78);

    // Define panning positions for 78 inputs across 6 outputs
    positions = \position.kr(0!78, 1/30, fixedLag:true);
    wdth = \width.kr(2!78, 1/30, fixedLag:true);  // Control the width of the panning

    // Pan each of the 78 input channels
    pannedSignals = Array.fill(78, { |i|
		PanAz.ar(6, signals[i], positions[i], 1, wdth[i])
    });

    // Sum the signals for each of the 6 output channels
    summedSignals = Array.fill(6, { |chan|
        pannedSignals.collect({ |sig|
            sig[chan]
        }).sum;
    });

    // Output the summed signals to the output bus
    Out.ar(out, summedSignals);
}).writeDefFile(d);
)

(
SynthDef.new(\panaz13to6, {
    arg in=0, out=0;
    var signals, pannedSignals, summedSignals, positions, wdth;

    // Read 78 channels from the input
    signals = In.ar(in, 13);

    // Define panning positions for 78 inputs across 6 outputs
    positions = \position.kr(0!13, 1/30, fixedLag:true);
    wdth = \width.kr(2!13, 1/30, fixedLag:true);  // Control the width of the panning

    // Pan each of the 78 input channels
    pannedSignals = Array.fill(13, { |i|
		PanAz.ar(6, signals[i], positions[i], 1, wdth[i])
    });

    // Sum the signals for each of the 6 output channels
    summedSignals = Array.fill(6, { |chan|
        pannedSignals.collect({ |sig|
            sig[chan]
        }).sum;
    });

    // Output the summed signals to the output bus
    Out.ar(out, summedSignals);
}).writeDefFile(d);
)


(
SynthDef.new(\panaz13multiar, {
    arg in=0, in2=0, out=0;
    var signals, pannedSignals, summedSignals, positions, wdth;


    wdth = \width.kr(2!13, 1/30, fixedLag: true);

    signals = In.ar(in, 13);
	positions = In.ar(in2, 13);
	positions=(positions*2)-1;

    // Pan each channel independently
    pannedSignals = Array.fill(13, { |i|
		PanAz.ar(13, signals[i], positions[i], 1, wdth[i])
    });

    // Sum the signals channel-wise
    summedSignals = Array.fill(13, { |chan|
        pannedSignals.collect({ |sig|
            sig[chan]
        }).sum;
    });

    Out.ar(out, summedSignals);
}).writeDefFile(d);
)

(
SynthDef.new(\panaz6multiar, {
    arg in=0, in2=0, out=0;
    var signals, pannedSignals, summedSignals, positions, wdth,wetdry,finalsig;

	wetdry=\wet.kr(1!6, 1/5, fixedLag: true);
	wdth = VarLag.kr(\width.kr(2!6),0.2);

    signals = In.ar(in, 6);
	positions = In.ar(in2, 6);
	positions=(positions*2)-1;

    // Pan each channel independently
    pannedSignals = Array.fill(6, { |i|
		PanAz.ar(6, signals[i], positions[i], 1, wdth[i])
    });

    // Sum the signals channel-wise
    summedSignals = Array.fill(6, { |chan|
        pannedSignals.collect({ |sig|
            sig[chan]
        }).sum;
    });

	finalsig=(summedSignals*wetdry)+(signals*(1-wetdry));
    Out.ar(out, summedSignals);
}).writeDefFile(d);
)
