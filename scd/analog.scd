(
~synthCreator.value("Analog", {|n|
	var p,pulsew,finalSig, waves;
	p = OceanodeParameter.ar(\pitch, 36, n, 0, 127, "vf");
	pulsew = OceanodeParameter.ar(\pw, 0, n, 0, 1, "vf");

	waves=[
		Saw.ar(p.midicps,1,0),
		LFTri.ar(p.midicps,0),
		Pulse.ar(p.midicps,(pulsew+0.5)%1,1),
		SinOsc.ar(p.midicps,0)
	];

	finalSig=Select.ar(OceanodeParameterDropdown.kr(\type, 0, n, "Saw:Triangle:Pulse:Sine"),waves);
	finalSig=finalSig * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);
	Out.ar(OceanodeOutput.kr(\out), finalSig);

}, description: "Analog synth with diferent wave types", category: "Source/Oscillator"
);
)
