This is a repository of synthdefs for the Oceanode framework. 

Oceanode uses the ofxSupercollider library to integrate communication with supercollider server, 
and it is capable of comunicating with synthdefs through custom graphic nodes.

This collection includes adaptations of "classic" synthdefs found on the internet, either at scccode.org and scsynth.org, github and online blogs,
as well as a huge collection of custom synths created by Playmodes. Feel free to re-use this codes for your own purposes!

Last and better commented and organized synthdefs are found at the SCD_V2 folder

File Tree, showing synth categories:
```
├── Effect
│   ├── Distortion
│   │   ├── asymparsat.scd
│   │   ├── decimator.scd
│   │   ├── distort.scd
│   │   ├── hardclip.scd
│   │   ├── multibanddistortion.scd
│   │   ├── multibandhardclip.scd
│   │   ├── multibandsineshaper.scd
│   │   ├── paramshaper.scd
│   │   ├── sigmoidshaper.scd
│   │   ├── sineshaper.scd
│   │   ├── softsaturator.scd
│   │   ├── tanh.scd
│   │   ├── transientshaper.scd
│   │   ├── wavefold.scd
│   │   └── waveshaper.scd
│   ├── Dynamics
│   │   ├── Sanitize.scd
│   │   ├── compressor.scd
│   │   ├── compressorb.scd
│   │   ├── compressorc.scd
│   │   ├── dccorrection.scd
│   │   ├── gain.scd
│   │   ├── limiter.scd
│   │   ├── lineargain.scd
│   │   ├── multibandcompressor.scd
│   │   ├── noisegate.scd
│   │   └── sidechain.scd
│   ├── Eq
│   │   ├── EQ5.scd
│   │   └── harmonicExciter.scd
│   ├── Filter
│   │   ├── HPF.scd
│   │   ├── LPF.scd
│   │   ├── bandpass.scd
│   │   ├── bandpassbank.scd
│   │   ├── comb.scd
│   │   ├── combfeed.scd
│   │   ├── filter4pole.scd
│   │   ├── filter_multimode.scd
│   │   ├── ladderfilter.scd
│   │   ├── monobandpassbank1080.scd
│   │   ├── moogfilter.scd
│   │   ├── moogvcf.scd
│   │   ├── notch.scd
│   │   ├── peakfilter.scd
│   │   ├── satfmfilter.scd
│   │   └── vadimfilter.scd
│   ├── Modulation
│   │   ├── ampmod.scd
│   │   ├── ringmod.scd
│   │   ├── tremolo.scd
│   │   └── vibrato.scd
│   ├── Pitch
│   │   ├── FreqShifter.scd
│   │   ├── GrainPitchShifter.scd
│   │   └── PitchShifter.scd
│   ├── Resonators
│   │   ├── amp_decays.txt
│   │   ├── bellResonator.scd
│   │   ├── brushedCymbalResonator.scd
│   │   ├── customresonator128.scd
│   │   ├── customresonator16.scd
│   │   ├── customresonator256.scd
│   │   ├── customresonator32.scd
│   │   ├── customresonator512.scd
│   │   ├── customresonator64.scd
│   │   ├── customresonator8.scd
│   │   ├── cymbalResonator.scd
│   │   ├── gamelanResonator.scd
│   │   ├── glassResonator.scd
│   │   ├── gongResonator.scd
│   │   ├── handpanResonator.scd
│   │   ├── kalimbaResonator.scd
│   │   ├── marimbaResonator.scd
│   │   ├── membraneResonator.scd
│   │   ├── metalResonator.scd
│   │   ├── plateResonator.scd
│   │   ├── ratios.txt
│   │   ├── sitarResonator.scd
│   │   ├── steelDrumResonator.scd
│   │   ├── stringResonator.scd
│   │   ├── templeBlockResonator.scd
│   │   └── woodBlockResonator.scd
│   ├── Spatial
│   ├── Spectral
│   │   ├── PV_BinShift.scd
│   │   ├── PV_Blur.scd
│   │   ├── PV_Brickwall.scd
│   │   ├── PV_HarmonicFilter.scd
│   │   ├── PV_Magabove.scd
│   │   ├── PV_Morph.scd
│   │   ├── PV_RectComb.scd
│   │   ├── blur.scd
│   │   ├── freqblur.scd
│   │   ├── pitchFilter.scd
│   │   └── vocoder.scd
│   └── Time
│       ├── Delay
│       │   ├── delay.scd
│       │   ├── delayfeed.scd
│       │   ├── echo.scd
│       │   ├── echoHold.scd
│       │   ├── echospat.scd
│       │   ├── echospat_expand.scd
│       │   ├── fftdelay.scd
│       │   ├── grainclouddelay.scd
│       │   ├── graindelay.scd
│       │   ├── overdub.scd
│       │   ├── pingpongecho.scd
│       │   ├── pitchdelay.scd
│       │   ├── spectraldelay.scd
│       │   ├── tapedelay.scd
│       │   └── triggeredGrainDelay.scd
│       ├── Freeze
│       │   ├── freeze.scd
│       │   ├── freezish.scd
│       │   └── grainfreeze.scd
│       ├── Granular
│       ├── Looping
│       │   ├── BeatRepeat.scd
│       │   ├── CircularBuffer.scd
│       │   ├── CircularBufferFFT.scd
│       │   ├── CircularBufferFFT2.scd
│       │   ├── Looper.scd
│       │   └── Stutter.scd
│       ├── Math
│       │   └── channelStatistics.scd
│       ├── Phase
│       │   ├── chorus.scd
│       │   ├── chorusb.scd
│       │   ├── flanger.scd
│       │   ├── flangerpitch.scd
│       │   ├── flangersync.scd
│       │   ├── phaseinvert.scd
│       │   ├── phaser.scd
│       │   ├── phaserb.scd
│       │   └── phaserc.scd
│       └── Reverb
│           ├── FDNReverb.scd
│           ├── FreeVerb.scd
│           ├── GreyholeReverb.scd
│           ├── JPVerb.scd
│           ├── LongReverb.scd
│           ├── grainReverb.scd
│           ├── primereverb.scd
│           ├── richreverb.scd
│           └── tankreverb.scd
├── InOut
│   └── input.scd
├── Mixing
├── Modulation
│   ├── Envelope
│   │   └── envelope.scd
│   ├── LFO
│   │   ├── lfo.scd
│   │   └── morphlfo.scd
│   ├── Ramps
│   │   ├── phasor.scd
│   │   ├── phasorhz.scd
│   │   ├── phasorpitch.scd
│   │   └── ramp.scd
│   └── Random
│       └── random.scd
├── Routing
│   ├── 4x4matrix.scd
│   ├── channelduplicator.scd
│   ├── channelrouter.scd
│   ├── channelsolo.scd
│   ├── multibandseparator.scd
│   ├── ntom.scd
│   └── shiftChannel.scd
├── Source
│   ├── Additive
│   │   └── additive.scd
│   ├── Analog
│   │   ├── MorphOsc.scd
│   │   ├── analog.scd
│   │   ├── blit.scd
│   │   ├── simpleimpulse.scd
│   │   ├── simplepulse.scd
│   │   ├── simplesaw.scd
│   │   ├── simplesine.scd
│   │   ├── squine.scd
│   │   ├── superpulse.scd
│   │   └── supersaw.scd
│   ├── FM
│   │   ├── FM2op.scd
│   │   ├── FMFeedback.scd
│   │   ├── fmgrain.scd
│   │   ├── kontour.scd
│   │   └── pmod.scd
│   ├── Feedback
│   │   ├── fbdrone.scd
│   │   ├── fbdronemod.scd
│   │   ├── feedback.scd
│   │   └── feedbackoscillator.scd
│   ├── Formants
│   │   ├── FMFormant.scd
│   │   └── Formants.scd
│   ├── Neural
│   ├── Noise
│   │   ├── click.scd
│   │   ├── geiger.scd
│   │   └── noise.scd
│   ├── Percussion
│   │   ├── 808
│   │   │   ├── clap808.scd
│   │   │   ├── claves808.scd
│   │   │   ├── cowbell808.scd
│   │   │   ├── cymbal808.scd
│   │   │   ├── hat808.scd
│   │   │   ├── kick808.scd
│   │   │   ├── maracas808.scd
│   │   │   ├── openhihat808.scd
│   │   │   ├── rimshot808.scd
│   │   │   ├── snare808.scd
│   │   │   └── tom808.scd
│   │   ├── abstractdrum.scd
│   │   ├── clap.scd
│   │   ├── fmperc.scd
│   │   ├── hihat.scd
│   │   ├── kickbestia.scd
│   │   ├── kickdrum.scd
│   │   ├── kickdrumb.scd
│   │   ├── kickdrumc.scd
│   │   ├── realisticsnare.scd
│   │   └── snare.scd
│   ├── PhysicalModelling
│   │   ├── baschet.scd
│   │   ├── bow.scd
│   │   ├── bowedCrystal.scd
│   │   ├── brass.scd
│   │   ├── brushedcymbal.scd
│   │   ├── cymbalcrash.scd
│   │   ├── cymbalpad.scd
│   │   ├── dwgclarinet.scd
│   │   ├── dwgflute.scd
│   │   ├── flute.scd
│   │   ├── framedrum.scd
│   │   ├── gamelan.scd
│   │   ├── glasspercussion.scd
│   │   ├── gongageng.scd
│   │   ├── handpan.scd
│   │   ├── junkpercussion.scd
│   │   ├── kalimba.scd
│   │   ├── karpluspluck.scd
│   │   ├── mallet.scd
│   │   ├── marimba.scd
│   │   ├── mdapiano.scd
│   │   ├── membrane.scd
│   │   ├── metal.scd
│   │   ├── metalplate.scd
│   │   ├── oteypiano.scd
│   │   ├── pluck.scd
│   │   ├── pluckResonator.scd
│   │   ├── prayerbell.scd
│   │   ├── sitar.scd
│   │   ├── steeldrum.scd
│   │   ├── templeblock.scd
│   │   ├── woodblock.scd
│   │   └── woodwind.scd
│   ├── Pulsar
│   │   ├── FMPulsar.scd
│   │   ├── Pulsar.scd
│   │   ├── Pulsar2.scd
│   │   ├── PulseTrain.scd
│   │   └── wavelet.scd
│   ├── Sampler
│   │   ├── BasicSampler.scd
│   │   ├── CrossLooper.scd
│   │   ├── FFTStretch.scd
│   │   ├── GrainSampler.scd
│   │   ├── OneShotSampler.scd
│   │   ├── PaulStretch.scd
│   │   ├── SamplerJump.scd
│   │   ├── SamplerStretch.scd
│   │   ├── SamplerSync.scd
│   │   └── paulstretch_multi.scd
│   ├── Special
│   │   ├── aliasingsynth.scd
│   │   ├── bubblea.scd
│   │   ├── bubbleb.scd
│   │   ├── buzzbass.scd
│   │   ├── frumbo.scd
│   │   ├── guttersynth.scd
│   │   ├── ikedabass.scd
│   │   ├── lissajous.scd
│   │   ├── recursive.scd
│   │   └── tb303.scd
│   ├── Stochastic
│   │   ├── gendy.scd
│   │   └── simplex.scd
│   ├── Sync
│   │   ├── HardSync.scd
│   │   ├── HardSyncBLPulse.scd
│   │   ├── HardSyncBLSaw.scd
│   │   ├── HardSyncPulse.scd
│   │   └── SyncSaw.scd
│   ├── Vector
│   │   ├── VectorSynth.scd
│   │   └── VectorSynthB.scd
│   └── WaveTable
│       └── WTSynth.scd
├── Spatial
│   ├── MidSide
│   │   └── midside.scd
│   ├── Panning
│   │   ├── dbap.scd
│   │   ├── multibandPanner.scd
│   │   ├── panaz.scd
│   │   ├── panazdoppler.scd
│   │   ├── panner.scd
│   │   └── xpanaz.scd
│   └── Perceptual
├── Utilities
│   ├── Analysis
│   │   └── spectralAnalyzer.scd
│   ├── Conversion
│   │   ├── conversions.scd
│   │   └── sig.scd
│   ├── Math
│   │   ├── arithmetics.scd
│   │   ├── logicops.scd
│   │   ├── mapper.scd
│   │   ├── quantize.scd
│   │   ├── trigonometry.scd
│   │   └── unaryop.scd
│   ├── Other
│   └── Voicing
│       └── impulsecounter.scd
└── reference_scd
    ├── analog.scd
    └── panner.scd


