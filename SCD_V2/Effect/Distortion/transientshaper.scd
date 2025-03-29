(
~synthCreator.value("TransientShaper", {|n|
	var divideFreq, transientVol, sustainVol, inSig, slewSig, sustainSig, transientSig, mixSig, dry, mix;

	// Parameters
	divideFreq = OceanodeParameter.ar(\dividefreq, 500, n, 20, 5000, "vf");
	transientVol = OceanodeParameter.ar(\transientvol, 1, n, 0, 4, "vf");
	sustainVol = OceanodeParameter.ar(\sustainvol, 1, n, 0, 4, "vf");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Input stage
	inSig = In.ar(OceanodeInput.kr(\in), n);
	dry = inSig;

	// Use slew to remove transients and higher frequencies
	slewSig = Slew.ar(inSig, divideFreq, divideFreq);
	sustainSig = slewSig * sustainVol;

	// Extract and process transients
	transientSig = (inSig - slewSig) * transientVol;

	// Mix sustain and transient signals
	mixSig = sustainSig + transientSig;

	// Apply gain reduction to avoid clipping
	mixSig = mixSig * 0.5;

	// Mix dry and wet signals
	mixSig = XFade2.ar(dry, mixSig, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), mixSig);
}, description: "Transient shaper for controlling attack and sustain portions of sounds", category: "Effect/Distortion");
)