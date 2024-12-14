(
SynthDef(\steam, {
    arg out=0;
    var steam, wnoiseamp, lpf, filterednoises, q, poles, dcnoise;

    // Steam generator parameters
    lpf = \lpf.kr(80).midicps;
	// Noise Cutoff. Sets the cutoff frequency of the noise signal.

    q = \q.kr(1);
	//Noise Filter Resonance. Sets the resonance of the filter applied to the noise signal. It is only active if poles>0

    poles = \poles.kr(0);
	// Filter Damping Amount. If 0, a 1-pole filter is used with 12 dB damping / octave. If 1, a 2-pole filter with 24 dB / octave is applied.

    dcnoise = \dcnoise.kr(0);
	//0 to 1. Impulse Source. Crossfades between the DC component at the left and the filtered noise, controlled in this section, at the right. The mixed signal is used as steam input of the resonating pipe.

    wnoiseamp = \amp.kr(0.5);
	//this parameter probably replaced by an envelope generator, to shape different impulse types.



    // Steam generator
    steam = WhiteNoise.ar() * wnoiseamp;
    filterednoises = [
        OnePole.ar(steam, exp(-2pi * (lpf / SampleRate.ir))),
        RLPF.ar(steam, lpf, q)
    ];
    steam = Select.ar(poles, filterednoises);
    steam = XFade2.ar(DC.ar(wnoiseamp), steam, dcnoise);

    Out.ar(out, steam);
}).add;
)

(
SynthDef(\pushpull, {
	arg out=0, in, in2;
	var inputsig1, inputsig2, finalsig, push, offset, polarity;
	    // Push-pull section parameters
    push = \push.kr(1);
	//0 to 2. Reverberating Steam Amount. Sets the amount of reverberating steam. Unlike the <Feedback> section wich is simulating the pipe itself, this section controls the air and its oscillation within the pipe.

    offset = \offset.kr(0);
	//-1 to 1. DC Offset. Sets the offset which is added to the reverberating steam signal. Unlike the <Feedback> section wich is simulating the pipe itself, this section controls the air and its oscillation within the pipe. Thus, this value influences a lot the amplitude interference between the new incoming steam and the reverberating steam inside the pipe. Note the connection with the <Polarity> parameter and try different values ...

    polarity = \pol.kr(1);
	//-1 or 1. Polarity. Switches the polarity of the pipe, simulating different modes of real pipes. Technically speaking, this value determines wether a phase inversion will be applied to the reverberating signal within the pipe. Refer also to the <Push-Pull> section.


	inputsig1=In.ar(in); //this is the steam signal
	inputsig2=In.ar(in2); //this is the feedback line

    // Push-pull mechanism
	finalsig = inputsig1 * ( (inputsig2 * push) + (offset * polarity) );

    Out.ar(out, finalsig);
}).add();
)

(
SynthDef(\asymParSat, {
	arg out=0, in=0;
	var sym, softhard,satpos,satneg,lopos,hipos,loneg,hineg,sympos,symneg,inputsig,eventclippos,eventclipneg,clippedsigpos,clippedsigneg,finalsig,satarray;

	softhard=\softhard.kr(0.5);
	//0 to 1. Saturation Mode. Controls the way of saturation. Decrease for soft saturation, Increase for clipping.

	hipos=softhard;
	hineg=softhard;

	sym=\sym.kr(0.5);
	//0 to 1. Saturation Symmetry. Controls the symmetry of saturation.

	sympos=sym+1;
	symneg=sym.neg+1;
	inputsig=In.ar(in);
	inputsig=SinOsc.ar(100);

	eventclippos=Clip.kr(hipos, 0.00001, 0.99999)*sympos;
	eventclipneg=Clip.kr(hineg, 0.00001, 0.99999)*symneg;
	clippedsigpos=Clip.ar(inputsig,eventclippos.neg,eventclippos);
	clippedsigneg=Clip.ar(inputsig,eventclipneg.neg,eventclipneg);

	satpos=((((eventclippos.neg)+sympos)*0.5)*SoftClipAmp.ar((((((eventclippos.neg)+sympos)*0.5).reciprocal)*(clippedsigpos.neg+inputsig))))+clippedsigpos;
	satneg=((((eventclipneg.neg)+symneg)*0.5)*SoftClipAmp.ar((((((eventclipneg.neg)+symneg)*0.5).reciprocal)*(clippedsigneg.neg+inputsig))))+clippedsigneg;

	satarray = [
		satpos,
		satneg
	];

	finalsig=Select.ar((inputsig+1)/2,satarray);

	Out.ar(out, finalsig);
}).play;
)

(
SynthDef(\AllPass, {
	arg in=0, out=0;
	var dly,dffs,pitch,inputsig,finalsig,processedsig,switch,sigarray,polarity;

	pitch=\pitch.kr(30);
	//midi pitch

	dffs=\diffussion.kr(0.001);
	//-1 to 1. Diffusion Amount. Sets the amount of diffusion within the additional delay unit. Technically speaking, with a value of 0 this unit becomes an allpass filter. Turn it to the left for additional attack effects of the pipe's sound. It also enhances the sound of harmonic frequencies which are not multiples of the main pitch, like e. g. in bells.

	switch=\allpassswitch.kr(1);
	// 0 or 1, off or on. Allpass Filter / Delay Switch. Turns the additional delay unit on or off. As it contains a diffusion control, it is very similar to an allpass filter. Its delay time can be adjusted in the <Allpass Tune> section. Switch on for additional attack effetcs of the pipe's sound.

	polarity=\pol.kr(1); //-1 or 1. Polarity. Switches the polarity of the pipe, simulating different modes of real pipes. Technically speaking, this value determines wether a phase inversion will be applied to the reverberating signal within the pipe. Refer also to the <Push-Pull> section.

	dly=(pitch.midicps).reciprocal; //defined in seconds

	inputsig=In.ar(in);
	inputsig=Saw.ar(30);
	inputsig=inputsig*polarity;
	inputsig=DelayL.ar(inputsig,0.2,dly);
	processedsig = ~diffuserDelay.(inputsig, dly, dffs);

	sigarray= [
		inputsig,
		processedsig
	];
	finalsig=Select.ar(switch,sigarray);
	Out.ar(out, finalsig);
}).play;
)

(
// Reusable function for diffuser delay
//processed = ~diffuserDelay.(saw, dly, dffs);
~diffuserDelay = { |input, dly=0.1, dffs=0.5|
    var feedback, delay, output;

    feedback = LocalIn.ar(1); // Feedback signal
	delay = DelayN.ar((input + feedback).tanh, 0.2, dly);
    output = (dffs.neg * input) + delay + (dffs * feedback);
    LocalOut.ar(output); // Send feedback for the next iteration

    output // Return the processed signal
};
)

(
SynthDef(\feedback, {
	arg in=0, out=0;
	var dly,rt,pitch,damp,gate,keytrack,rtparam,mixlev;
	var inputsig,finalsig;

	keytrack=\keytrack.kr(1);
	//0 to 2. RT Key tracking. Sets the amount of key tracking applied to the feedback's reverberation time. increase for longer reverb times at high MIDI pitches.

	gate=\gate.kr(1);
	//0 to 1 (note velocity)

	damp=\damp.kr(60);
	//0 to 120. RT Key-Up Damping. Sets the amount of damping applied to the pipe at Key-Up, i. e. at MIDI gate off events.

	rtparam=\rt.kr(2);
	//-90 to 30. Reverberation Time. Adjusts the time of the pipe's reverberation, i. e. the amount of damping applied to the feedback's signal before it is mixed again with the new incoming signal. The longer the reverb time, the more the incoming noise steam signal becomes a tone with reckognizable pitch.

	pitch=\pitch.kr(60);
	//midi pitch

	dly=(pitch.midicps).reciprocal;

	inputsig=In.ar(in);

	rt=((pitch-60)*keytrack)+(((gate.neg+1)*damp)+rtparam);
	rt=(rt.midicps).reciprocal;
	mixlev=((dly/rt)*60).neg;

	finalsig=mixlev.dbamp*inputsig;

	Out.ar(out, finalsig);

}).add;
)

(
SynthDef(\mwfilter, {
	arg out=0, in=0;
	var modwheel,hp0,hp1,lp0,lp1,hpktrack,lpktrack,hpcut,lpcut,pitch;
	var inputsig, finalsig;

	pitch=\pitch.kr(80);

	modwheel=\modwheel.kr(0.5);//0 to 1

	hpktrack=\hpktrack.kr(1); //0 to 2. Highpass Cutoff Key Tracking. Controls the amount of key tracking applied to the highpss filter's cutoff frequency. Increase for higher cutoff frequencies at high MIDI pitches.

	lpktrack=\lpktrack.kr(0); //-2 to 2. Lowpass Cutoff Key Tracking. Controls the amount of key tracking applied to the lowpass filter's cutoff frequency. Increase for higher cutoff frequencies at high MIDI pitches.

	hp0=\hp0.kr(12); //0 to 120. Highpass Cutoff Frequency Low. Sets the cutoff frequency of an additional highpass filter within the pipe to enhance certain segments of the frequency spectrum of the signal (the formants of the pipe). Those formants are not modified by the tone's pitch, but by its pressure. By using the MIDI modulation wheel, this pressure can be controlled: At low modulation wheel values this knob is used to determine the formant's frequency, at high mod. wheel values the knob at the right adjusts the formant. Refer also to the <MW> knobs in the <Del Tune> and <Allpass Tune> sections for further influence possibilities of the modulation wheel.

	hp1=\hp1.kr(66); //0 to 120. Highpass Cutoff Frequency High.

	lp0=\lp0.kr(66); //0 to 120. Lowpass Cutoff Frequency Low. Sets the cutoff frequencz of an additional lowpass filter within the pipe to enhance certain segments of the frequency spectrum of the signal (the formants of the pipe). Those formants are not modified by the tone's pitch, but by its pressure. By using the MIDI modulation wheel, this pressure can be controlled: At low modulation wheel values this knob is used to determine the formant's frequency, at high mod. wheel values the knob at the right adjusts the formant. Refer also to the <MW> knobs in the <Del Tune> and <Allpass Tune> sections for further influence possibilities of the MIDI modulation wheel.

	lp1=\lp1.kr(96); //0 to 120. Lowpass Cutoff Frequency High.

	inputsig=In.ar(in);

	pitch=pitch-60;
	hpcut=XFade2.kr(hp0,hp1,modwheel);
	hpcut=hpcut+(hpktrack*pitch);
	lpcut=XFade2.kr(lp0,lp1,modwheel);
	lpcut=lpcut+(lpktrack*pitch);

	finalsig=LPF.ar(HPF.ar(inputsig,hpcut),lpcut);
	Out.ar(out, finalsig);

}).add;
)

(
SynthDef(\pipeModel, {
    // Common parameters
    arg out=0;
    var pitch = \pitch.kr(36),
        polarity = \pol.kr(-1),
        modwheel = \modwheel.kr(0.415);

    // Steam generator parameters
    var lpf = \lpf.kr(60).midicps,
        q = \q.kr(1),
        poles = \poles.kr(0),
        dcnoise = \dcnoise.kr(1),
        wnoiseamp = \amp.kr(0.5);

    // Push-pull parameters
    var push = \push.kr(0.15),
        offset = \offset.kr(0.152);

    // Allpass parameters
    var dffs = \diffussion.kr(0.525),
        allpassswitch = \allpassswitch.kr(1);

    // Asymmetric saturation parameters
    var softhard = \softhard.kr(0.515),
        sym = \sym.kr(0.0615);

    // MW filter parameters
    var hpktrack = \hpktrack.kr(1),
        lpktrack = \lpktrack.kr(1),
        hp0 = \hp0.kr(12),
        hp1 = \hp1.kr(66),
        lp0 = \lp0.kr(66),
        lp1 = \lp1.kr(96);

    // Feedback parameters
    var keytrack = \keytrack.kr(1),
        gate = \gate.kr(1),
        damp = \damp.kr(90),
        rtparam = \rt.kr(30);

    // Internal routing variables
    var steam, filterednoises, pushpullOut, allpassOut, diffuserOut,
        asymsatOut, mwfilterOut, feedbackOut, dly, rt, mixlev,
        eventclippos, eventclipneg, clippedsigpos, clippedsigneg,
        satpos, satneg, finalsig,
        hipos, hineg, sympos, symneg,
        hpcut, lpcut, pitchOffset,
        feedback, delay;

    // Initialize feedbackOut with silence
    feedbackOut = DC.ar(0);

    // Steam generator
    steam = WhiteNoise.ar() * wnoiseamp;
    filterednoises = [
        OnePole.ar(steam, exp(-2pi * (lpf / SampleRate.ir))),
        RLPF.ar(steam, lpf, q)
    ];
    steam = Select.ar(poles, filterednoises);
    steam = XFade2.ar(DC.ar(wnoiseamp), steam, dcnoise);

    // Calculate delay time from pitch
    dly = pitch.midicps.reciprocal;

    // Push-pull mechanism with limiting
    pushpullOut = (steam * ((feedbackOut * push) + (offset * polarity))).clip2(1.0);

    // Allpass/diffuser section
    allpassOut = pushpullOut * polarity;
    allpassOut = DelayL.ar(allpassOut, 0.2, dly);

    // Integrated diffuser delay with controlled feedback
    feedback = LocalIn.ar(1);
    feedback = LeakDC.ar(feedback);
    delay = DelayN.ar(allpassOut + (feedback * 0.5707), 0.2, dly);
    diffuserOut = (dffs.neg * allpassOut) + delay + (dffs * feedback);
    diffuserOut = diffuserOut.tanh;
    LocalOut.ar(diffuserOut);

    allpassOut = Select.ar(allpassswitch, [allpassOut, diffuserOut]);

    // Asymmetric saturation
    hipos = softhard;
    hineg = softhard;
    sympos = sym + 1;
    symneg = sym.neg + 1;

    eventclippos = Clip.kr(hipos, 0.00001, 0.99999) * sympos;
    eventclipneg = Clip.kr(hineg, 0.00001, 0.99999) * symneg;
    clippedsigpos = Clip.ar(allpassOut, eventclippos.neg, eventclippos);
    clippedsigneg = Clip.ar(allpassOut, eventclipneg.neg, eventclipneg);

    satpos = ((((eventclippos.neg)+sympos)*0.5) *
             SoftClipAmp.ar((((((eventclippos.neg)+sympos)*0.5).reciprocal) *
             (clippedsigpos.neg + allpassOut)))) + clippedsigpos;

    satneg = ((((eventclipneg.neg)+symneg)*0.5) *
             SoftClipAmp.ar((((((eventclipneg.neg)+symneg)*0.5).reciprocal) *
             (clippedsigneg.neg + allpassOut)))) + clippedsigneg;

    asymsatOut = Select.ar((allpassOut+1)/2, [satpos, satneg]);

    // MW filter section
    pitchOffset = pitch - 60;
    hpcut = XFade2.kr(hp0, hp1, modwheel) + (hpktrack * pitchOffset);
    lpcut = XFade2.kr(lp0, lp1, modwheel) + (lpktrack * pitchOffset);
    mwfilterOut = LPF.ar(HPF.ar(asymsatOut, hpcut.midicps), lpcut.midicps);

    // Feedback section with additional safety
    rt = ((pitch-60) * keytrack) + (((gate.neg+1) * damp) + rtparam);
    rt = rt.midicps.reciprocal;
    mixlev = ((dly/rt) * 60).neg;
    feedbackOut = (mixlev.dbamp * mwfilterOut).clip2(1.0);

    finalsig = LeakDC.ar(mwfilterOut).clip2(1.0);

    // Proper CheckBadValues syntax
    CheckBadValues.ar(finalsig, id: 0);

    Out.ar(out, finalsig);
}).play;
)

(
SynthDef(\steampipe, {
    // Common parameters
    arg out=0;
    var pitch = \pitch.kr(46),
        polarity = \pol.kr(1),
        modwheel = \modwheel.kr(0.15);

    // Steam generator parameters
    var lpf = \lpf.kr(0).midicps,
        q = \q.kr(1),
        poles = \poles.kr(1),
        dcnoise = \dcnoise.kr(1),
        wnoiseamp = \amp.kr(0.5);

    // Push-pull parameters
    var push = \push.kr(0.1),
        offset = \offset.kr(1);

    // Allpass parameters
    var dffs = \diffussion.kr(3.985),
        allpassswitch = \allpassswitch.kr(1);

    // Asymmetric saturation parameters
    var softhard = \softhard.kr(0.25),
        sym = \sym.kr(0.5);

    // MW filter parameters
    var hpktrack = \hpktrack.kr(1),
        lpktrack = \lpktrack.kr(1),
        hp0 = \hp0.kr(12),
        hp1 = \hp1.kr(66),
        lp0 = \lp0.kr(66),
        lp1 = \lp1.kr(96);

    // Feedback parameters
    var keytrack = \keytrack.kr(1),
        gate = \gate.kr(1),
        damp = \damp.kr(60),
        rtparam = \rt.kr(-90);

    // Internal routing variables
    var steam, filterednoises, pushpullOut, allpassOut, diffuserOut,
        asymsatOut, mwfilterOut, feedbackOut, dly, rt, mixlev,
        eventclippos, eventclipneg, clippedsigpos, clippedsigneg,
        satpos, satneg, finalsig,
        hipos, hineg, sympos, symneg,
        hpcut, lpcut, pitchOffset,
        feedback, delay;

    // Initialize feedbackOut with silence
    feedbackOut = DC.ar(0);

    // Calculate precise delay time from pitch
    dly = pitch.midicps.reciprocal;

    // Steam generator with improved filtering
    steam = WhiteNoise.ar() * wnoiseamp;
    filterednoises = [
        OnePole.ar(steam, exp(-2pi * (lpf / SampleRate.ir))),
        RLPF.ar(steam, lpf, q)
    ];
    steam = Select.ar(poles, filterednoises);
    steam = XFade2.ar(DC.ar(wnoiseamp), steam, dcnoise);

    // Push-pull mechanism with controlled feedback
    pushpullOut = steam * ((feedbackOut * push * 0.5) + (offset * polarity));
    pushpullOut = LeakDC.ar(pushpullOut);

    // Allpass/diffuser section with controlled resonance
    allpassOut = pushpullOut * polarity;
    allpassOut = DelayC.ar(allpassOut, 0.2, dly); // Using DelayC for better interpolation

    // Integrated diffuser with controlled feedback
    feedback = LocalIn.ar(1);
    feedback = LeakDC.ar(feedback);
    delay = DelayC.ar(allpassOut + (feedback * dffs * 0.4), 0.2, dly);
    diffuserOut = (allpassOut * (dffs.neg * 0.5)) + delay;
    diffuserOut = LeakDC.ar(diffuserOut).tanh;
    LocalOut.ar(diffuserOut * 0.8); // Reduced feedback amount

    allpassOut = Select.ar(allpassswitch, [allpassOut, diffuserOut]);

    // Asymmetric saturation
    hipos = softhard;
    hineg = softhard;
    sympos = sym + 1;
    symneg = sym.neg + 1;

    eventclippos = Clip.kr(hipos, 0.00001, 0.99999) * sympos;
    eventclipneg = Clip.kr(hineg, 0.00001, 0.99999) * symneg;
    clippedsigpos = Clip.ar(allpassOut, eventclippos.neg, eventclippos);
    clippedsigneg = Clip.ar(allpassOut, eventclipneg.neg, eventclipneg);

    satpos = ((((eventclippos.neg)+sympos)*0.5) *
             SoftClipAmp.ar((((((eventclippos.neg)+sympos)*0.5).reciprocal) *
             (clippedsigpos.neg + allpassOut)))) + clippedsigpos;

    satneg = ((((eventclipneg.neg)+symneg)*0.5) *
             SoftClipAmp.ar((((((eventclipneg.neg)+symneg)*0.5).reciprocal) *
             (clippedsigneg.neg + allpassOut)))) + clippedsigneg;

    asymsatOut = Select.ar((allpassOut+1)/2, [satpos, satneg]);

    // MW filter section
    pitchOffset = pitch - 60;
    hpcut = XFade2.kr(hp0, hp1, modwheel) + (hpktrack * pitchOffset);
    lpcut = XFade2.kr(lp0, lp1, modwheel) + (lpktrack * pitchOffset);
    mwfilterOut = LPF.ar(HPF.ar(asymsatOut, hpcut.midicps), lpcut.midicps);

    // Feedback section with improved control
    rt = ((pitch-60) * keytrack) + (((gate.neg+1) * damp) + rtparam);
    rt = rt.midicps.reciprocal;
    mixlev = ((dly/rt) * 60).neg;
    feedbackOut = (mixlev.dbamp * mwfilterOut).tanh;

    finalsig = LeakDC.ar(mwfilterOut);

    Out.ar(out, finalsig.dup);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
