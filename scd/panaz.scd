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

(
SynthDef.new(\panaz6, {
	arg in=0, out=0;
	var monosig, pannedSig, pos, wdth;

	pos = \position.kr(0!6,  1/30, fixedLag: true);  // Expanded control-rate position
	wdth = \width.kr(2!6,  1/30, fixedLag: true);    // Expanded control-rate width

	monosig = In.ar(in, 1);

	// Pan each channel independently using the expanded control signals

	pannedSig=PanAz.ar(6, monosig, pos, 1, wdth);


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
SynthDef.new(\xpanaz13, {
    arg in=0, out=0;
    var numChans=13;
    var signals, frontSignals, backSignals, summedSignals;
    var x, widths, rotation;
    var frontPos, backPos;

    x = \x.kr(0.5!numChans, 1/30, fixedLag:true);
	x=x/2;
    widths = \width.kr(2!numChans, 1/30, fixedLag:true);
	rotation = 0.4188; //cuidado! hardcoded per al cas de 13ch de astres (amb indexat de speaker cw)

    signals = In.ar(in, numChans);

    frontSignals = Array.fill(numChans, { |i|
        frontPos = x[i] * 2 - 1;  // x: 0->-1, 0.5->0, 1->1
        frontPos = (frontPos + rotation).wrap(-1, 1);
        PanAz.ar(numChans, signals[i], frontPos, 1, widths[i]);
    });

    backSignals = Array.fill(numChans, { |i|
        backPos = x[i] * -2 + 1;  // x: 0->1, 0.5->0, 1->-1
        backPos = (backPos + rotation).wrap(-1, 1);
        PanAz.ar(numChans, signals[i], backPos, 1, widths[i]);
    });

    summedSignals = Array.fill(numChans, { |chan|
        var front = frontSignals.collect({ |sig| sig[chan] }).sum;
        var back = backSignals.collect({ |sig| sig[chan] }).sum;
        (front + back) * 0.5;
    });

    Out.ar(out, summedSignals);
}).writeDefFile(d);
)


d = thisProcess.nowExecutingPath.dirname;

(
SynthDef.new(\panaz13multihaas, {
    arg in=0, out=0;
    var signals, delayedSignals, pannedSignals, summedSignals, positions, wdth, haasAmount;

    positions = \position.kr(0!13, 1/30, fixedLag:true);
    wdth = \width.kr(2!13, 1/30, fixedLag:true);
    haasAmount = \haas.kr(0!13, 1/30, fixedLag:true);

    signals = In.ar(in, 13);

    delayedSignals = if(
        haasAmount.sum < 0.000001, // Check if all haas values are effectively zero
        signals,
        Array.fill(13, { |i|
            var delayTimes = Array.fill(13, { |j|
                var distance = (positions[i] - (j/13)).abs;
                distance * haasAmount[i];
            });
            DelayC.ar(signals[i], 0.05, delayTimes);
        })
    );

    pannedSignals = Array.fill(13, { |i|
        PanAz.ar(13, delayedSignals[i], positions[i], 1, wdth[i])
    });

    summedSignals = Array.fill(13, { |chan|
        pannedSignals.collect({ |sig|
            sig[chan]
        }).sum;
    });

    Out.ar(out, summedSignals);
}).writeDefFile(d);
)

(
SynthDef.new(\panaz6multi, {
    arg in=0, out=0;
    var signals, pannedSignals, summedSignals, positions, wdth;

    positions = \position.kr(0!6, 1/30, fixedLag:true);
    wdth = \width.kr(2!6, 1/30, fixedLag:true);

    signals = In.ar(in, 6);

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
    positions = \position.kr(0!78, 1/4, fixedLag:true);
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
SynthDef.new(\panaz78to13, {
    arg in=0, out=0;
    var signals, pannedSignals, summedSignals, positions, wdth;

    // Read 78 channels from the input
    signals = In.ar(in, 78);

    // Define panning positions for 78 inputs across 6 outputs
    positions = \position.kr(0!78, 1/4, fixedLag:true);
    wdth = \width.kr(2!78, 1/30, fixedLag:true);  // Control the width of the panning

    // Pan each of the 78 input channels
    pannedSignals = Array.fill(78, { |i|
		PanAz.ar(13, signals[i], positions[i], 1, wdth[i])
    });

    // Sum the signals for each of the 6 output channels
    summedSignals = Array.fill(13, { |chan|
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
    positions = (positions*2)-1;

    // Add equal-power compensation
    pannedSignals = Array.fill(13, { |i|
        var compensated;
        compensated = PanAz.ar(13, signals[i], positions[i], 1, wdth[i]);
        compensated = compensated * (wdth[i].sqrt.reciprocal);  // Compensate for width
        compensated;
    });

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
    Out.ar(out, finalsig);
}).writeDefFile(d);
)

(
SynthDef.new(\shiftchannels13, {
    arg in=0, in2=0, out=0;
    var signals, shiftedSignals, shift;

    signals = In.ar(in, 13); // Assuming 'in' is the starting bus channel for the input signals
	shift = In.ar(in2, 1)*13;

    shiftedSignals = Array.fill(13, { |i|
        var baseIndex, nextIndex, frac, signal1, signal2, mixSig;

        baseIndex = (i + shift.floor).mod(13);
        nextIndex = (baseIndex + 1).mod(13);
        frac = shift - shift.floor;

        signal1 = SelectX.ar(baseIndex, signals);  // Corrected usage
        signal2 = SelectX.ar(nextIndex, signals); // Corrected usage

        mixSig = XFade2.ar(signal1, signal2, frac * 2 - 1);

        mixSig;
    });

    Out.ar(out, shiftedSignals);
}).writeDefFile(d);
)

(
SynthDef.new(\shiftchannels6, {
    arg in=0, in2=0, out=0;
    var signals, shiftedSignals, shift;

    signals = In.ar(in, 6); // Assuming 'in' is the starting bus channel for the input signals
	shift = In.ar(in2, 1)*6;

    shiftedSignals = Array.fill(6, { |i|
        var baseIndex, nextIndex, frac, signal1, signal2, mixSig;

        baseIndex = (i + shift.floor).mod(6);
        nextIndex = (baseIndex + 1).mod(6);
        frac = shift - shift.floor;

        signal1 = SelectX.ar(baseIndex, signals);  // Corrected usage
        signal2 = SelectX.ar(nextIndex, signals); // Corrected usage

        mixSig = XFade2.ar(signal1, signal2, frac * 2 - 1);

        mixSig;
    });

    Out.ar(out, shiftedSignals);
}).writeDefFile(d);
)









