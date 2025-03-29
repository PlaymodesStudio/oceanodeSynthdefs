(
~synthCreator.value("Sanitize", {|n|
	var source, sig, level, corrected, send;

	source = In.ar(OceanodeInput.kr(\in), n);

    // Apply DC correction
    corrected = Sanitize.ar(source);

    // Output the DC corrected signal
	Out.ar(OceanodeOutput.kr(\out), corrected);

}, description: "Replaces infinities NaNs and subnormal numbers with 0", category: "Effect/Dynamics");
)

