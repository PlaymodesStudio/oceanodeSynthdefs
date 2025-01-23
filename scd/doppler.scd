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
    var signals, pannedSignals, summedSignals, wdth, x, y, distance, amplitude, azimuth, panValue, filt, filtmin, filtmax, filtrange, falloffRate;

    signals = In.ar(in,13);
	wdth = \width.kr(2!13, 1/30, fixedLag:true);
	x = \x.kr(10!13, 1/30, fixedLag:true);
	y = \y.kr(1!13, 1/30, fixedLag:true);

    distance = hypot(x, y);

    falloffRate = \falloff.kr(1!13, 1/30, fixedLag:true);
	amplitude = 1 / (1 + (distance * falloffRate).squared);

	filtmin = \cutmin.kr(20!13);
	filtmax = \cutmax.kr(130!13);
	filtrange = filtmax-filtmin;
	filt = (amplitude*filtrange)+filtmin;
	filt = filt.clip(20,130);
	filt = filt.midicps;

    azimuth = atan2(y, x);
    panValue = (azimuth / pi).clip2(1);

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

(
SynthDef.new(\panazdoppler13b, {
    arg in=0, out=0;
    var nch=13;
    var signals, pannedSignals, summedSignals, wdth, x, y, z, distance;
    var amplitude, azimuth, panValue;
    var velX, velY, approachVel, pitchShift;
    var directSig, reflSig, finalSig;
    var roomHeight, roomWidth, falloffRate;
    var ceilingDist, floorDist, wallDist;
    var reflCoef, ceilingAmp, floorAmp, wallAmp;
    var ceilingPan, floorPan, wallPan;
    var sig, ceiling, floor, wall;
    var filtmin, filtmax, filtrange, filt;
    var reverbAmount, reverbDistance, reverbSend, reverbSig, wetLevel, dryLevel;
    var centralityAmount, centralFactor;
    var minFreq = 20, maxFreq = 20000;
    var currentHPFreq, currentLPFreq;
    var dopplerAmount; // New variable for doppler control

    // Add doppler amount control parameter
    dopplerAmount = \doppler.kr(1!nch);

    // Room dimensions for reflections
    roomHeight = \roomheight.kr(5);
    roomWidth = \roomwidth.kr(8);

    // Rest of your room and reverb parameters
    reverbAmount = \reverbamount.kr(0.3!nch);
    reverbDistance = \reverbdistance.kr(0.5!nch);

    // Input and position controls
    signals = In.ar(in,nch);
    wdth = \width.kr(2!nch, 1/30, fixedLag:true);
    x = \x.kr(10!nch, 1/30, fixedLag:true);
    y = \y.kr(1!nch, 1/30, fixedLag:true);
    z = \z.kr(0!nch, 1/30, fixedLag:true);

    centralityAmount = \centrality.kr(1!13);

    // Calculate velocities for doppler using Slope UGen
    velX = Slope.kr(x);
    velY = Slope.kr(y);

    // Basic calculations
    distance = hypot(x, y);
    azimuth = atan2(y, x);

    // Improved amplitude falloff
    falloffRate = \falloff.kr(1!nch, 1/30, fixedLag:true);
    amplitude = 1 / (1 + (distance * falloffRate).squared);

    // Modified doppler effect calculation with control
    approachVel = (x*velX + y*velY) / (distance + 0.001);
	pitchShift = 1 - (approachVel/344 * dopplerAmount);  // Changed + to -

    // Rest of your code remains the same
    filtmin = \cutmin.kr(20!nch);
    filtmax = \cutmax.kr(130!nch);
    filtrange = filtmax-filtmin;
    filt = (amplitude*filtrange)+filtmin;
    filt = filt.clip(20,130);
    filt = filt.midicps;

    ceilingDist = hypot(x, roomHeight*2 - y);
    floorDist = hypot(x, y.neg);
    wallDist = hypot(roomWidth*2 - x, y);

    reflCoef = \reflectioncoef.kr(0.3);
    ceilingAmp = reflCoef / (1 + (ceilingDist * falloffRate).squared);
    floorAmp = reflCoef / (1 + (floorDist * falloffRate).squared);
    wallAmp = reflCoef / (1 + (wallDist * falloffRate).squared);

    ceilingPan = (atan2(roomHeight*2 - y, x) / pi).clip2(1);
    floorPan = (atan2(y.neg, x) / pi).clip2(1);
    wallPan = (atan2(y, roomWidth*2 - x) / pi).clip2(1);

    panValue = (azimuth / pi).clip2(1);

    pannedSignals = Array.fill(nch, { |i|
        sig = signals[i];

        currentHPFreq = Select.kr(z[i] > 0, [
            minFreq,
            z[i].linexp(0, 1, minFreq, maxFreq)
        ]);

        currentLPFreq = Select.kr(z[i] < 0, [
            maxFreq,
            z[i].neg.linexp(0, 1, maxFreq, minFreq)
        ]);

        sig = HPF.ar(sig, currentHPFreq);
        sig = LPF.ar(sig, currentLPFreq);

        sig = PitchShift.ar(sig, 0.2, pitchShift[i], 0, 0.01);

        sig = LPF.ar(sig, filt[i]);

        wetLevel = (reverbAmount[i] * (distance[i] * reverbDistance[i]).squared).clip(0, 1);
        dryLevel = 1.0 - (wetLevel * 0.5);

        reverbSig = PanAz.ar(nch,
            FreeVerb.ar(
                sig,
                mix: 1,
                room: \reverbroom.kr(0.7),
                damp: \reverbdamp.kr(0.5)
            ) * wetLevel,
            panValue[i],
            1,
            wdth[i]
        );

        centralFactor = (centralityAmount[i] / (1 + (distance[i]))).clip(0, 1);

        directSig = Mix([
            PanAz.ar(nch,
                DelayC.ar(sig, 110/344, distance[i]/344),
                panValue[i],
                amplitude[i] * (1 - centralFactor),
                wdth[i]
            ),
            Array.fill(nch, {
                DelayC.ar(sig, 110/344, distance[i]/344) *
                amplitude[i] *
                centralFactor *
                (1/nch)
            })
        ]);

        ceiling = PanAz.ar(nch,
            DelayC.ar(sig, 110/344, ceilingDist[i]/344),
            ceilingPan[i],
            ceilingAmp[i],
            wdth[i]
        );

        floor = PanAz.ar(nch,
            DelayC.ar(sig, 110/344, floorDist[i]/344),
            floorPan[i],
            floorAmp[i],
            wdth[i]
        );

        wall = PanAz.ar(nch,
            DelayC.ar(sig, 110/344, wallDist[i]/344),
            wallPan[i],
            wallAmp[i],
            wdth[i]
        );

        (directSig + ceiling + floor + wall) * dryLevel + reverbSig
    });

    summedSignals = Array.fill(nch, { |chan|
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
    panValue = (azimuth / pi).clip2(1);

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