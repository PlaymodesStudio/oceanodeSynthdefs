(//stereo downmixer
SynthDef.new(\stereomix, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 78);
	sig=Splay.ar(sig,1,1,0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//stereo downmixer
SynthDef.new(\stereomix13, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 13);
	sig=Splay.ar(sig,1,1,0);
	ReplaceOut.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef.new(\circularstereomix13, {
    arg in, out=0;
	var numChannels=13;
    var sig, positions;

    positions = {|i|
        var idx = i + 1;
        var rightSegment = (numChannels - 1) / 2;

        Select.kr(
            (idx == 1).asInteger,
            [
                Select.kr(
                    (idx <= (rightSegment + 1)).asInteger,
                    [
                        sin(2pi * (numChannels - idx + 1) / (numChannels - 1)) * -1,  // left side
                        sin(2pi * (idx - 1) / (numChannels - 1))  // right side
                    ]
                ),
                0  // center
            ]
        )
    } ! numChannels;

    sig = In.ar(in, numChannels);
    sig = Array.fill(numChannels, {|i|
        Pan2.ar(sig[i], positions[i], 1)
    }).sum;

    ReplaceOut.ar(out, sig);
}).writeDefFile(d);
)

(//stereo downmixer
SynthDef.new(\stereomix48, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 48);
	sig=Splay.ar(sig,1,1,0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
