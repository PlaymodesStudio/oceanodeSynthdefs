(
~synthCreator.value("GrainDelay", {|n|
	var cf, echoes;
	var del, dens, graindur, pan, amp;
	var sigin, sig, panctrl, mix, send;
	
	// Parameters
	panctrl = OceanodeParameterLag.ar(\pan, 0, n, -1, 1, "vf", 1/30, true);
	amp = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
	del = OceanodeParameterLag.ar(\delay, 0.25, n, 0.01, 1, "vf", 1/30, true);
	dens = OceanodeParameterLag.ar(\density, 30, n, 1, 100, "vf", 1/30, true);
	graindur = OceanodeParameterLag.ar(\graindur, 0.07, n, 0.01, 0.5, "vf", 1/30, true);
	echoes = OceanodeParameterLag.ar(\echoes, 12, n, 1, 30, "vf", 1/30, true);
	cf = OceanodeParameterLag.ar(\lowcut, 130, n, 20, 130, "vf", 1/30, true).midicps;
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);
	
	// Input processing
	sigin = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply low-pass filter with send parameter
	sig = LPF.ar(sigin * send, cf);
	
	// Apply comb filter delay
	sig = CombL.ar(sig, del, del, del * echoes);
	
	// Apply granular processing
	sig = GrainIn.ar(n, Dust.kr(dens), graindur, sig, panctrl);
	
	// Apply amplitude
	sig = sig * amp;
	
	// Mix dry and wet signals
	sig = (sigin * (1-mix)) + (sig * mix);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Granular delay effect with variable density and grain duration", category: "Effect/Time/Delay", variables: [], variableDimensions: []);
)