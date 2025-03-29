(
~synthCreator.value("Trigonometry", {|n|
    var input, output, operationIndex, scaledInput, scaleInput;

    // Input audio signal
    input = In.ar(OceanodeInput.kr(\in), n);

    // Add a scaling parameter to determine whether to scale 0-1 to 0-2π
     scaleInput = OceanodeParameter.kr(\radians, 1, n, 0, 1, "vi");

    // Scale input to radians if needed (assuming 0-1 input range)
    scaledInput = input * 2pi * scaleInput + (input * (1-scaleInput));

    // Operation dropdown selector
    operationIndex = OceanodeParameterDropdown.kr(\operation, 0, n, "Sin:Cos:Tan:Sinh:Cosh:Tanh:ASin:ACos:ATan");

    // Apply selected trigonometric operation
    output = Select.ar(operationIndex, [
        scaledInput.sin,      // Sin
        scaledInput.cos,      // Cos
        scaledInput.tan,      // Tan
        scaledInput.sinh,     // Sinh
        scaledInput.cosh,     // Cosh
        scaledInput.tanh,     // Tanh
        scaledInput.asin,     // ASin
        scaledInput.acos,     // ACos
        scaledInput.atan      // ATan
    ]);

    // Output the processed signal
    Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Apply various trigonometric and mathematical operations to audio signals", category: "Utilities/Math");
)