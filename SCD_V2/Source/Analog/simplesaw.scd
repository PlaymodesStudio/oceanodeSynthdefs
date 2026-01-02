(
~synthCreator.value("SimpleSaw", {|n|
	var freq, signal, ampControl, phase, trigger, reset;

	// Pitch control with lag for smooth transitions
	freq = OceanodeParameterLag.ar(\hz, 440, n, 0, 20000, "vf", 1/30, true);

	// Reset trigger control - when this goes from 0 to positive, it will reset the phase
	trigger = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");

	// Create reset signal that creates a trigger when the control value changes to positive
	reset = Trig.kr(trigger, 0.001);

	// Create sawtooth oscillator with phase reset ability
	phase = Phasor.ar(reset, freq/SampleRate.ir, 0, 1);
	signal = (phase * 2 - 1);

	// Apply level control with proper dB scaling
	ampControl = OceanodeParameterLag.ar(\amp, 0, n, 0, 1, "vf", 1/30, true);

	// Apply amplitude
	signal = signal * ampControl;

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), signal);

}, description: "Sawtooth oscillator with phase reset for hard sync effects", category: "Source/Analog");
)