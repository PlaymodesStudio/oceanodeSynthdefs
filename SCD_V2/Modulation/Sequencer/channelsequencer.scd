(
~synthCreator.value("ChannelSequencer", {|n, variables|
	var phaseIn, numSteps, stepValues, stepValues2, stepValues3;
	var phasor, currentStep, prevStep;
	var stepTrig, stepValue, stepValue2, stepValue3;
	var channelIndex;
	var triggerArray, valueArray, valueArray2, valueArray3;
	var maxSteps;

	// Maximum number of steps
	maxSteps = 64;

	// Input parameters (hardcoded to size 1 for scalar inputs)
	phaseIn = OceanodeParameter.ar(\phasor, 0, 1, 0, 1, "vf"); // Phasor input (0-1 range)
	numSteps = OceanodeParameter.ar(\numsteps, 8, 1, 2, maxSteps, "vi"); // Number of steps

	// Step value arrays (one value per step)
	stepValues = OceanodeParameter.ar(\stepvalues, 0, maxSteps, 0, 1, "vf"); // Primary step values
	stepValues2 = OceanodeParameter.ar(\stepvalues2, 0, maxSteps, 0, 1, "vf"); // Secondary step values
	stepValues3 = OceanodeParameter.ar(\stepvalues3, 0, maxSteps, 0, 1, "vf"); // Tertiary step values

	// Scale the phasor to the number of steps
	phasor = phaseIn * numSteps;

	// Get current step and values
	currentStep = phasor.floor.clip(0, numSteps - 1);
	stepValue = Select.ar(currentStep, stepValues);
	stepValue2 = Select.ar(currentStep, stepValues2);
	stepValue3 = Select.ar(currentStep, stepValues3);

	// Detect step changes
	prevStep = DelayN.ar(currentStep, 0.1, SampleDur.ir);
	stepTrig = (currentStep - prevStep).abs.sign;

	// Channel index that increments with each step
	channelIndex = Stepper.ar(stepTrig.asArray[0], 0, 0, n-1, 1, 0);

	// Initialize output arrays
	triggerArray = Array.fill(n, 0);
	valueArray = Array.fill(n, 0);
	valueArray2 = Array.fill(n, 0);
	valueArray3 = Array.fill(n, 0);

	// Route to each channel using Latch to hold values
	n.do { |i|
		var channelActive, chanTrig;

		// Check if this channel is active (using subtraction and absolute value)
		channelActive = 1.0 - ((channelIndex - i).abs.clip(0, 1));
		chanTrig = channelActive * stepTrig.asArray[0];

		// Set trigger
		triggerArray[i] = chanTrig;

		// Use Latch to hold the values when this channel is triggered
		valueArray[i] = Latch.ar(stepValue.asArray[0], chanTrig);
		valueArray2[i] = Latch.ar(stepValue2.asArray[0], chanTrig);
		valueArray3[i] = Latch.ar(stepValue3.asArray[0], chanTrig);
	};

	// Output signals
	Out.ar(OceanodeOutput.kr(\triggerout), triggerArray);
	Out.ar(OceanodeOutput.kr(\valueout), valueArray);
	Out.ar(OceanodeOutput.kr(\valueout2), valueArray2);
	Out.ar(OceanodeOutput.kr(\valueout3), valueArray3);
}, description: "Routes multiple value sequences across channels", category: "Modulation/Sequencer");
)