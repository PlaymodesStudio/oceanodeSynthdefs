(
~synthCreator.value("DCCorrection", {|n|
	var source, sig, level, corrected, send;

	source = In.ar(OceanodeInput.kr(\in), n);

    // Apply DC correction
    corrected = LeakDC.ar(source);

    // Output the DC corrected signal
	Out.ar(OceanodeOutput.kr(\out), corrected);

}, description: "DC Correction", category: "Effect/Dynamics");
)

