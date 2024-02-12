(
SynthDef.new(\holdreverb13, {
    arg in, out=0;
	var feedback = \feedback.kr(0.5!13);
	var mx=\mix.kr(0!13);
	var ing=\inputgain.kr(1!13);
	var dry, wet;
    var sig, local;

    // Expand the input signal to 13 channels. Assuming the source is mono.
    sig = In.ar(in,13)*ing;

    // Initialize the local signal for 13 channels.
    local = LocalIn.ar(13) + sig;

    // Apply the all-pass filter chain to each channel.
    30.do {
        local = local.collect { |channel|
            AllpassN.ar(channel, 0.06, Rand(0.001,0.06), 3);
        };
    };

    // Feedback the processed signal, taking care to scale by feedback amount.
    LocalOut.ar(local * feedback);
	wet=local*mx;
	dry=sig*(1-mx);
    // Output the mix of dry and wet signals.
    Out.ar(out, wet+dry);
}).writeDefFile(d);
)

(
SynthDef.new(\holdfilteredreverb13, {
    arg in, out=0;
	var filters=0;
	var feedback = \feedback.kr(0.5!13);
	var mx=\mix.kr(0!13);
	var ing=\inputgain.kr(1!13);
	var dry, wet;
    var sig, local;
	var cut=\cutoff.kr(60!13, 1/30, fixedLag:true).midicps;
	var res=\resonance.kr(0.2!13);
	var selfilt=\filtertype.kr(0!13);

    // Expand the input signal to 13 channels. Assuming the source is mono.
    sig = In.ar(in,13)*ing;

    // Initialize the local signal for 13 channels.
    local = LocalIn.ar(13) + sig;

    // Apply the all-pass filter chain to each channel.
    30.do {
        local = local.collect { |channel|
            AllpassN.ar(channel, 0.06, Rand(0.001,0.06), 3);
        };
    };

	filters=[
		RLPF.ar(local,cut,1-res,1,0),
		RHPF.ar(local,cut,1-res,1,0),
		BPF.ar(local,cut,1-res,1,0),
		BPeakEQ.ar(local,cut,1,res*12,1,0)
	];

    // Feedback the processed signal, taking care to scale by feedback amount.
    LocalOut.ar(filters * feedback);
	wet=local*mx;
	dry=sig*(1-mx);
    // Output the mix of dry and wet signals.
    Out.ar(out, wet+dry);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;