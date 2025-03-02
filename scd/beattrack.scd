d = thisProcess.nowExecutingPath.dirname;

d = thisProcess.nowExecutingPath.dirname;

(
File.mkdir(d ++ "/" ++ "BeatTrack");
(1..100).do({arg n;
    var numChan = n;
    SynthDef("BeatTrack" ++ numChan.asSymbol, {
        arg in, lockTime=1, threshold=0.1, beatBus=0, tempoBus=1, confidenceBus=2, phaseBus=3;
        var input = In.ar(in, numChan);
        // Mix down to mono for beat tracking
        var monoInput = Mix(input) / numChan;
        var amp = Amplitude.kr(monoInput);
        var fft = FFT(LocalBuf(512), monoInput);
        var track = AutoTrack.kr(fft, lockTime);

        // Only process if we have enough signal
        var active = amp > threshold;

        // track returns: [beat trigger, tempo, phase, locked]
        var beat = track[0] * active;          // Beat trigger (0 or 1)
        var tempo = track[1] * active;         // Tempo in BPM
        var phase = track[2] * active;         // Phase (0-1)
        var locked = track[3] * active;        // Whether tracker is locked (0 or 1)

        // Calculate confidence based on lock status and signal presence
        var confidence = RunningSum.kr(locked * active, 20).lag(0.1) * 0.05;
        confidence = confidence.clip(0, 1);  // Ensure confidence is 0-1

        // Output to control buses
        Out.kr(beatBus, beat);
        Out.kr(tempoBus, tempo);
        Out.kr(confidenceBus, confidence);
        Out.kr(phaseBus, phase);

        // Output silence (we're only interested in control signals)
        Silent.ar();
    }).writeDefFile(d ++ "/BeatTrack");
});
)

d = thisProcess.nowExecutingPath.dirname;

(
File.mkdir(d ++ "/" ++ "TestLFO");
(1..100).do({arg n;
    var numChan = n;
    SynthDef.new("TestLFO" ++ (numChan).asSymbol, {
        arg out=0;
        // Simple 1Hz sine wave LFO that outputs to a control bus
        Out.kr(out, SinOsc.kr(1).range(0, 1));
    }).writeDefFile(d ++ "/TestLFO");
});
)

(
File.mkdir(d ++ "/" ++ "PitchTracker");
(1..100).do({arg n;
	var numChan = n;
	SynthDef.new("PitchTracker" ++ (numChan).asSymbol, {
		arg in, pitch, lagTime = 0.2;
		var sig;
		sig = In.ar(in, numChan);
		Out.kr(pitch, Lag.kr(Pitch.kr(sig, ampThreshold: 0.02, median: 7), lagTime));
	}).writeDefFile(d ++ "/PitchTracker");
})
)


(
SynthDef(\autotrack,{
arg out,in;
var trackb,trackh,trackq,tempo;
var source;
var bsound,hsound,qsound;
var temp, quart,half,beat;

source= In.ar(in,1);

#trackb,trackh,trackq,tempo=AutoTrack.kr(source);

bsound= LPF.ar(WhiteNoise.ar*(Decay.kr(trackb,0.05)),1000);

hsound= BPF.ar(WhiteNoise.ar*(Decay.kr(trackh,0.05)),3000,0.66);

qsound= HPF.ar(WhiteNoise.ar*(Decay.kr(trackq,0.05)),5000);

	temp=(tempo*60).poll;
	quart=Decay.kr(trackq,0.003).ceil.poll;
	beat=Decay.kr(trackb,0.003).ceil.poll;
	half=Decay.kr(trackb,0.003).ceil.poll;

Out.ar(out, bsound+hsound+qsound);
}).play;
)

(
File.mkdir(d ++ "/" ++ "BeatTracker");
SynthDef.new("BeatTracker", {
    arg in, temp, quart, beat, half;
    var source, trackb, trackh, trackq, tempo;

    source = In.ar(in, 1); // Single channel input

    #trackb, trackh, trackq, tempo = AutoTrack.kr(source);

    // Output control rate signals
    Out.kr(temp, tempo * 60);  // Convert to BPM
    Out.kr(quart, Decay.kr(trackq, 0.003).ceil);
    Out.kr(beat, Decay.kr(trackb, 0.003).ceil);
    Out.kr(half, Decay.kr(trackh, 0.003).ceil);
}).writeDefFile(d ++ "/BeatTracker");
)