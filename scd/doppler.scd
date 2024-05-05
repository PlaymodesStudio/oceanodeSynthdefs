(
{
    var x, y, distance, velocity, pitchRatio, amplitude, azimuth, panValue;
    // object travels 200 meters in 6 secs (=120kph) passing 10 meters
    // from the listener
    x = 10;
    y = LFSaw.kr(1/6, 0, 100);
    distance = hypot(x, y);
    velocity = Slope.kr(distance);
    pitchRatio = (344 - velocity) / 344;  // speed of sound is 344 meters/sec
    amplitude = 10 / distance.squared;
    azimuth = atan2(y, x); // azimuth in radians
    panValue = (azimuth / 0.5pi).clip2(1);
    Pan2.ar(FSinOsc.ar(1000 * pitchRatio), panValue, amplitude)
}.play)

(
{
    var x, y, distance, velocity, pitchRatio, amplitude, motorSound,
            azimuth, panValue;
    // object travels 200 meters in 6 secs (=120kph) passing 10 meters
    // from the listener
    x = 10;
    y = LFSaw.kr(1/6, 0, 100);
    distance = hypot(x, y);
    amplitude = 40 / distance.squared;
    motorSound = RLPF.ar(FSinOsc.ar(200, 0, LFPulse.ar(31.3, 0, 0.4)), 400, 0.3);
    azimuth = atan2(y, x); // azimuth in radians
    panValue = (azimuth / 0.5pi).clip2(1); // make a value for Pan2 from azimuth
    PanAz.ar(DelayL.ar(motorSound, 110/344, distance/344), panValue, amplitude)
}.play)

(
SynthDef.new(\doppler, {
	arg out=0,in=0;
	var x, y, distance, amplitude, motorSound,
            azimuth, panValue,sig;
    // object travels 200 meters in 6 secs (=120kph) passing 10 meters
    // from the listener
	sig = In.ar(in, 2);
	x = \x.kr(10, 1/30, fixedLag:true);
	y = \y.kr(1, 1/30, fixedLag:true);
    distance = hypot(x, y);
    amplitude = 40 / distance.squared;
    azimuth = atan2(y, x); // azimuth in radians
    panValue = (azimuth / 0.5pi).clip2(1); // make a value for Pan from azimuth
    sig=PanAz.ar(2, DelayL.ar(sig, 110/344, distance/344), panValue, amplitude);
	Out.ar(out, sig);
}).play();
)



(
SynthDef.new(\panazdoppler13, {
	arg in=0, out=0;
    var signals, pannedSignals, summedSignals, wdth, x, y, distance, amplitude, azimuth, panValue,filt,filtmin,filtmax,filtrange;

    signals = In.ar(in,13);

	wdth = \width.kr(2!13, 1/30, fixedLag:true);
	x = \x.kr(10!13, 1/30, fixedLag:true);
	y = \y.kr(1!13, 1/30, fixedLag:true);
    distance = hypot(x, y);
	amplitude = (40 / distance.squared);

	filtmin=\cutmin.kr(20!13);
	filtmax=\cutmax.kr(130!13);
	filtrange=filtmax-filtmin;
	filt=(amplitude*filtrange)+filtmin;
	filt=filt.clip(20,130);
	filt=filt.midicps;

    azimuth = atan2(y, x); // azimuth in radians
    panValue = (azimuth / 0.5pi).clip2(1);

    // Pan each channel independently
    pannedSignals = Array.fill(13, { |i|
		PanAz.ar(13, DelayC.ar(LPF.ar(signals[i],filt[i]), 110/344, distance[i]/344), panValue[i], amplitude[i], wdth[i])
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


d = thisProcess.nowExecutingPath.dirname;

(
SynthDef.new(\panazdoppler6, {
	arg in=0, out=0;
    var signals, pannedSignals, summedSignals, wdth, x, y, distance, amplitude, azimuth, panValue,filt,filtmin,filtmax,filtrange;

    signals = In.ar(in,6);

	wdth = \width.kr(2!6, 1/30, fixedLag:true);
	x = \x.kr(10!6, 1/30, fixedLag:true);
	y = \y.kr(1!6, 1/30, fixedLag:true);
    distance = hypot(x, y);
	amplitude = (40 / distance.squared);

	filtmin=\cutmin.kr(20!6);
	filtmax=\cutmax.kr(130!6);
	filtrange=filtmax-filtmin;
	filt=(amplitude*filtrange)+filtmin;
	filt=filt.clip(20,130);
	filt=filt.midicps;

    azimuth = atan2(y, x); // azimuth in radians
    panValue = (azimuth / 0.5pi).clip2(1);

    // Pan each channel independently
    pannedSignals = Array.fill(6, { |i|
		PanAz.ar(6, DelayC.ar(LPF.ar(signals[i],filt[i]), 110/344, distance[i]/344), panValue[i], amplitude[i], wdth[i])
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