(
~synthCreator.value("PanAz", {|n, variables|
	var source, signal, position, level, width, orientation, numSpeakers;
	numSpeakers = variables[0];
	position = OceanodeParameterLag.ar(\position, 0, n, 0, 2, "vf", 1/30, true);
	level = OceanodeParameter.kr(\level, 1, n, 0, 1, "vf");
	width = OceanodeParameter.ar(\width, 2, n, 0, 2, "vf");
	orientation = OceanodeParameter.kr(\orientation, 0.5, 1, 0, 1, "f");
	source = In.ar(OceanodeInput(\in), n);
	source = source.asArray;
	signal = PanAz.ar(numSpeakers, source, position, level, width, orientation).flop.collect(Mix(_));
	Out.ar(OceanodeOutput.kr(\out), signal);
}, category: "Effect/Downmixer", variables: ["NumSpeakers"], variableDimensions: [64]);
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

(
SynthDef.new(\xpanaz78to13, {
    arg in=0, out=0;
    var numChans=13;
    var signals, frontSignals, backSignals, summedSignals;
    var x, widths, rotation;
    var frontPos, backPos;

    x = \x.kr(0.5!78, 1/30, fixedLag:true);
	x=x/2;
    widths = \width.kr(2!78, 1/30, fixedLag:true);
	rotation = 0.4188; //cuidado! hardcoded per al cas de 13ch de astres (amb indexat de speaker cw)

    signals = In.ar(in, 78);

    frontSignals = Array.fill(78, { |i|
        frontPos = x[i] * 2 - 1;  // x: 0->-1, 0.5->0, 1->1
        frontPos = (frontPos + rotation).wrap(-1, 1);
        PanAz.ar(numChans, signals[i], frontPos, 1, widths[i]);
    });

    backSignals = Array.fill(78, { |i|
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









