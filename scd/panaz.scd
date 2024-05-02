(//Panner 6chan
SynthDef.new(\panaz6, {
	arg in, out=0;
	var sig, pos=1,wdth=2;
	pos=\position.ar(0); //range -1 to 1
	wdth=\width.kr(2);
	sig = In.ar(in, 1);
	sig=PanAz.ar(6,sig,pos,1,wdth);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef.new(\panaz13, {
	arg in=0, out=0;
	var monosig, pannedSig, pos, wdth;

	pos = \position.kr(0);  // Expanded control-rate position
	wdth = \width.kr(2);    // Expanded control-rate width

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

    positions = \position.kr(0!13);
    wdth = \width.kr(2);

    signals = In.ar(in, 13);

    // Pan each channel independently
    pannedSignals = Array.fill(13, { |i|
        PanAz.ar(13, signals[i], positions[i], 1, wdth)
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
SynthDef.new(\panaz13multiar, {
    arg in=0, in2=0, out=0;
    var signals, pannedSignals, summedSignals, positions, wdth, gainin, gainout;


    wdth = \width.kr(2!13, 1/30, fixedLag:true);
	gainin=\levelsin.kr(1!13, 1/30, fixedLag:true);
	gainout=\levelsout.kr(1!13, 1/30, fixedLag:true);

    signals = In.ar(in, 13);
	signals=signals*gainin;

	positions = In.ar(in2, 13);

    // Pan each channel independently
    pannedSignals = Array.fill(13, { |i|
        PanAz.ar(13, signals[i], positions[i], 1, wdth)
    });

    // Sum the signals channel-wise
    summedSignals = Array.fill(13, { |chan|
        pannedSignals.collect({ |sig|
            sig[chan]
        }).sum;
    });

    Out.ar(out, summedSignals*gainout);
}).writeDefFile(d);
)
