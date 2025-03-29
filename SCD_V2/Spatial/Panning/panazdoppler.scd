(
~synthCreator.value("PanAzDoppler", {|n|
	var signals, pannedSignals, summedSignals, width, posX, posY, distance, amplitude, azimuth, panValue, filt, filtmin, filtmax, filtrange, falloffRate;

	// Input signals
	signals = In.ar(OceanodeInput.kr(\in), n);

	// Parameters with proper lag for smooth transitions
	width = OceanodeParameterLag.ar(\width, 2, n, 1, 13, "vf", 1/30, true);
	posX = OceanodeParameterLag.ar(\position_x, 1, n, -20, 20, "vf", 1/30, true);
	posY = OceanodeParameterLag.ar(\position_y, 1, n, -20, 20, "vf", 1/30, true);
	falloffRate = OceanodeParameterLag.ar(\falloff, 1, n, 0.1, 5, "vf", 1/30, true);

	// Filter parameters
	filtmin = OceanodeParameter.ar(\cutmin, 20, n, 20, 130, "vf");
	filtmax = OceanodeParameter.ar(\cutmax, 130, n, 20, 130, "vf");

	// Calculate distance and amplitude based on falloff
	distance = hypot(posX, posY);
	amplitude = 1 / (1 + (distance * falloffRate).squared);

	// Calculate filter frequency
	filtrange = filtmax - filtmin;
	filt = (amplitude * filtrange) + filtmin;
	filt = filt.clip(20, 130);
	filt = filt.midicps;

	// Calculate pan position
	azimuth = atan2(posY, posX);
	panValue = (azimuth / pi).clip2(1);

	// Process each channel with spatial effects
	pannedSignals = Array.fill(n, { |i|
		var sig = signals[i];
		sig = LPF.ar(sig, filt[i]);
		sig = DelayC.ar(sig, 110/344, distance[i]/344);
		PanAz.ar(n, sig, panValue[i], amplitude[i], width[i])
	});

	// Sum the signals channel-wise
	summedSignals = Array.fill(n, { |chan|
		pannedSignals.collect({ |sig|
			sig[chan]
		}).sum;
	});

	// Output the processed signals
	Out.ar(OceanodeOutput.kr(\out), summedSignals);

}, description: "Spatial panner with doppler effect", category: "Spatial/Panning");
)

(
~synthCreator.value("PanAzDopplerComplex", {|n|
	var signals, pannedSignals, summedSignals, wdth, posX, posY, posZ, distance;
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
	var dopplerAmount;

	// Input signals
	signals = In.ar(OceanodeInput.kr(\in), n);

	// Parameters with proper lag for smooth transitions
	wdth = OceanodeParameterLag.ar(\width, 2, n, 1, 13, "vf", 1/30, true);
	posX = OceanodeParameterLag.ar(\posx, 1, n, -20, 20, "vf", 1/30, true);
	posY = OceanodeParameterLag.ar(\posy, 1, n, -20, 20, "vf", 1/30, true);
	posZ = OceanodeParameterLag.ar(\posz, 0, n, -1, 1, "vf", 1/30, true);
	falloffRate = OceanodeParameterLag.kr(\falloff, 1, n, 0.1, 5, "vf", 1/30, true);

	// Room and reflection parameters
	roomHeight = OceanodeParameter.kr(\room_height, 4, n, 0, 20, "vf");
	roomWidth = OceanodeParameter.kr(\room_width, 8, n, 0, 20, "vf");
	reflCoef = OceanodeParameter.kr(\reflection_coef, 0, n, 0, 1, "vf");

	// Reverb parameters
	reverbAmount = OceanodeParameter.kr(\reverb_amount, 0.3, n, 0, 1, "vf");
	reverbDistance = OceanodeParameter.kr(\reverb_distance, 0.5, n, 0, 2, "vf");

	// Filter parameters
	filtmin = OceanodeParameter.kr(\cut_min, 20, n, 20, 130, "vf");
	filtmax = OceanodeParameter.kr(\cut_max, 130, n, 20, 130, "vf");

	// Other effect controls
	dopplerAmount = OceanodeParameter.kr(\doppler, 1, n, 0, 3, "vf");
	centralityAmount = OceanodeParameter.kr(\centrality, 1, n, 0, 5, "vf");

	// Calculate velocities for doppler using Slope UGen
	velX = Slope.ar(posX);
	velY = Slope.ar(posY);

	// Basic calculations
	distance = hypot(posX, posY);
	azimuth = atan2(posY, posX);

	// Improved amplitude falloff
	amplitude = 1 / (1 + (distance * falloffRate).squared);

	// Modified doppler effect calculation with control
	approachVel = (posX*velX + posY*velY) / (distance + 0.001);
	pitchShift = 1 - (approachVel/344 * dopplerAmount);

	// Filter frequency calculation
	filtrange = filtmax - filtmin;
	filt = (amplitude*filtrange) + filtmin;
	filt = filt.clip(20, 130);
	filt = filt.midicps;

	// Reflection calculations
	ceilingDist = hypot(posX, roomHeight*2 - posY);
	floorDist = hypot(posX, posY.neg);
	wallDist = hypot(roomWidth*2 - posX, posY);

	ceilingAmp = reflCoef / (1 + (ceilingDist * falloffRate).squared);
	floorAmp = reflCoef / (1 + (floorDist * falloffRate).squared);
	wallAmp = reflCoef / (1 + (wallDist * falloffRate).squared);

	ceilingPan = (atan2(roomHeight*2 - posY, posX) / pi).clip2(1);
	floorPan = (atan2(posY.neg, posX) / pi).clip2(1);
	wallPan = (atan2(posY, roomWidth*2 - posX) / pi).clip2(1);

	panValue = (azimuth / pi).clip2(1);

	// Process each channel with spatial effects
	pannedSignals = Array.fill(n, { |i|
		sig = signals[i];

		// Z position controlling high/low pass filters
		currentHPFreq = Select.kr(posZ[i] > 0, [
			minFreq,
			posZ[i].linexp(0, 1, minFreq, maxFreq)
		]);

		currentLPFreq = Select.kr(posZ[i] < 0, [
			maxFreq,
			posZ[i].neg.linexp(0, 1, maxFreq, minFreq)
		]);

		sig = HPF.ar(sig, currentHPFreq);
		sig = LPF.ar(sig, currentLPFreq);

		// Doppler effect
		sig = PitchShift.ar(sig, 0.2, pitchShift[i], 0, 0.01);

		// Distance-based filtering
		sig = LPF.ar(sig, filt[i]);

		// Reverb level based on distance
		wetLevel = (reverbAmount[i] * (distance[i] * reverbDistance[i]).squared).clip(0, 1);
		dryLevel = 1.0 - (wetLevel * 0.5);

		// Create reverb signal
		reverbSig = PanAz.ar(n,
			FreeVerb.ar(
				sig,
				mix: 1,
				room: OceanodeParameter.ar(\reverb_room, 0.7, n, 0, 1, "vf")[i],
				damp: OceanodeParameter.ar(\reverb_damp, 0.5, n, 0, 1, "vf")[i]
			) * wetLevel,
			panValue[i],
			1,
			wdth[i]
		);

		// Calculate centrality factor for positioning
		centralFactor = (centralityAmount[i] / (1 + (distance[i]))).clip(0, 1);

		// Direct signal with centrality control
		directSig = Mix([
			PanAz.ar(n,
				DelayC.ar(sig, 110/344, distance[i]/344),
				panValue[i],
				amplitude[i] * (1 - centralFactor),
				wdth[i]
			),
			Array.fill(n, {
				DelayC.ar(sig, 110/344, distance[i]/344) *
				amplitude[i] *
				centralFactor *
				(1/n)
			})
		]);

		// Create reflections
		ceiling = PanAz.ar(n,
			DelayC.ar(sig, 110/344, ceilingDist[i]/344),
			ceilingPan[i],
			ceilingAmp[i],
			wdth[i]
		);

		floor = PanAz.ar(n,
			DelayC.ar(sig, 110/344, floorDist[i]/344),
			floorPan[i],
			floorAmp[i],
			wdth[i]
		);

		wall = PanAz.ar(n,
			DelayC.ar(sig, 110/344, wallDist[i]/344),
			wallPan[i],
			wallAmp[i],
			wdth[i]
		);

		// Mix everything together
		(directSig + ceiling + floor + wall) * dryLevel + reverbSig
	});

	// Sum the signals channel-wise
	summedSignals = Array.fill(n, { |chan|
		pannedSignals.collect({ |sig|
			sig[chan]
		}).sum;
	});

	// Output the processed signals
	Out.ar(OceanodeOutput.kr(\out), summedSignals);

}, description: "Advanced spatial panner with doppler and reflections", category: "Spatial/Panning");
)