(
{
    var snd, freq, formantCount, formantFreq, sineCycles, pulsaretPhase, window;
	freq= 10; //entre 0 i 1000
	formantFreq= 1000;//entre 2 i 8000
	sineCycles= 4;//entre 1 i 1000

    pulsaretPhase = LFSaw.ar(freq, iphase: 1).linlin(-1, 1, 0, 1) * formantFreq / freq;
    window = pulsaretPhase.lincurve(0, 1, 1, 0, -4);
    snd = sin(pulsaretPhase * 2pi * sineCycles.floor) * window * (pulsaretPhase < 1);
}.play(fadeTime: 0);
)

d = thisProcess.nowExecutingPath.dirname;


(
SynthDef.new(\pulsar, {
	arg out=0;
	var snd, freq, formantCount, formantFreq, sineCycles, pulsaretPhase, window;
	freq= VarLag.kr(\freq.kr(10!13),1/30); //entre 0 i 1000
	formantFreq= VarLag.kr(\formantfreq.kr(1000!13),1/30);//entre 2 i 8000
	sineCycles= \cycles.kr(4!13);//entre 1 i 1000

    pulsaretPhase = LFSaw.ar(freq, iphase: 1).linlin(-1, 1, 0, 1) * formantFreq / freq;
    window = pulsaretPhase.lincurve(0, 1, 1, 0, -4);
    snd = sin(pulsaretPhase * 2pi * sineCycles.floor) * window * (pulsaretPhase < 1);

	Out.ar(out, snd);
}).writeDefFile(d);
)

(
{
    var snd, freq, formantCount, formantFreq, sineCycles, pulsaretPhase, window, randomLFO, randomLFOs, lfoRate;
    formantCount = 3;
    lfoRate = LFDNoise1.kr(0.3).linexp(-1, 1, 0.1, 16);
    randomLFO = {
        var trigger;
        trigger = Dust.kr(lfoRate);
        Select.kr(ToggleFF.kr(trigger), [
            LFNoise2.kr(lfoRate),
            TRand.kr(-1, 1, trigger)
        ]);
    };
    randomLFOs = { { randomLFO.() } ! formantCount };
    freq = randomLFO.().linexp(-1, 1, 1, 1000);
    formantFreq = randomLFOs.().linexp(-1, 1, 2, 8000);
    sineCycles = randomLFOs.().linlin(-1, 1, 1, 4);
    pulsaretPhase = LFSaw.ar(freq, iphase: 1).linlin(-1, 1, 0, 1) * formantFreq / freq;
    window = pulsaretPhase.lincurve(0, 1, 1, 0, -4);
    snd = sin(pulsaretPhase * 2pi * sineCycles.floor) * window * (pulsaretPhase < 1);
    snd = snd * randomLFOs.().linlin(-1, 1, 0, 1);
    snd = Pan2.ar(snd, randomLFOs.() * 0.4);
    snd = snd.flop.sum;
    [0.2, 0.1, 0.05].do { |windowSize|
        snd = PitchShift.ar(snd, windowSize, randomLFO.().linexp(-1, 1, 0.5, 2)) * 6.dbamp;
        snd = FreqShift.ar(snd, randomLFO.() * 100);
    };
    snd = Limiter.ar(snd);
    snd = snd * -2.dbamp;
    snd;
}.play(fadeTime: 0);
)