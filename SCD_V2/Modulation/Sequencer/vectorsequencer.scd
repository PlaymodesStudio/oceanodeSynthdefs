(
~synthCreator.value("VectorSequencer", {|n, variables|
	var phaseIn, numSteps, stepValues;
	var currentStep, prevStep, phasor;
	var stepTrigger, stepValue, holdValue;
	var triggerOut, valueOut;
	var maxSteps;

	// Maximum number of steps
	maxSteps = 64;

	// Input parameters
	phaseIn = OceanodeParameter.ar(\phasor, 0, n, 0, 1, "vf"); // Phasor input (0-1 range)
	numSteps = OceanodeParameter.ar(\numsteps, 8, n, 2, maxSteps, "vi"); // Number of steps
	stepValues = OceanodeParameter.ar(\stepvalues, 0, maxSteps, 0, 1, "vf"); // Step values (0-1 range)

	// Scale the phasor to the number of steps
	phasor = phaseIn * numSteps;

	// Get the current step (0 to numSteps-1)
	currentStep = phasor.floor.clip(0, numSteps - 1);

	// Detect step changes using one-sample delay
	prevStep = DelayN.ar(currentStep, 2/SampleRate.ir, 1/SampleRate.ir);
	stepTrigger = (currentStep - prevStep) > 0;

	// Also trigger on first step when the phasor resets from 1 to 0
	stepTrigger = stepTrigger + (prevStep > currentStep);

	// Get the value for the current step
	stepValue = Select.ar(currentStep, stepValues);

	// Generate trigger output (momentary 1 when crossing a step with value > 0)
	// Create initial trigger when starting from zero to handle the first step
	triggerOut = (stepTrigger * (stepValue > 0)) > 0;

	// Also trigger when first starting (if not already triggered)
	triggerOut = triggerOut + (Impulse.ar(0) * (stepValue > 0));

	// Hold the value until next step (using Latch)
	holdValue = Latch.ar(stepValue, stepTrigger);
	valueOut = holdValue;

	// Output the trigger and value
	Out.ar(OceanodeOutput.kr(\triggerout), triggerOut);
	Out.ar(OceanodeOutput.kr(\valueout), valueOut);

}, description: "Vector step sequencer with trigger and value outputs", category: "Modulation/Sequencer");
)