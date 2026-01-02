(
~synthCreator.value("MidSide", {|n|
    var input, mid, side, mix;

    // Input multichannel signal
    input = In.ar(OceanodeInput.kr(\in), n);
    input = input.asArray;  // Ensure it's an array for calculations

    // Calculate mid as the average of all channels
    mid = Mix.new(input) / n;

    // Calculate side for each channel (each channel minus the mid)
    side = input - mid;

    // Apply level controls with natural curve
    mid = mid * OceanodeParameterLag.ar(\midlevel, 1, 1, 0, 1, "vf", 1/30, true);
    side = side * OceanodeParameterLag.ar(\sidelevel, 1, n, 0, 1, "vf", 1/30, true);

    // Duplicate the mid signal to match the number of output channels
    mid = Array.fill(n, { mid });

	mix = mid + side;

    // Output mid and side to their respective output buses
    Out.ar(OceanodeOutput.kr(\midout), mid);
    Out.ar(OceanodeOutput.kr(\sideout), side);
	Out.ar(OceanodeOutput.kr(\mixout), mix);

}, description: "Separates multichannel signal into mid and side components", category: "Spatial/MidSide");
)