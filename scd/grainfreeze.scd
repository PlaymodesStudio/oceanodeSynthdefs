d = thisProcess.nowExecutingPath.dirname;

(
SynthDef.new(\grainfreeze,{
	arg out= 0;
	var point= \point.kr(0);
	var pitch= 1;
	var glide= 0.3;
	var gate= \gate.kr(0);
	var wSize= 0.1;
	var playback=\play.kr(0);
	var rate= 0.1;
	var bufnum, signal, input, mix;
	input= In.ar(0,2);
	bufnum= LocalBuf(s.sampleRate*2, 2); // recording 2 seconds
	RecordBuf.ar(input, bufnum, 0, 1, 0, (gate-1).abs, 1, gate);
	point = [Lag.kr(point, glide), LFSaw.kr(rate).abs, SinOsc.kr(rate).abs, LFTri.kr(rate).abs, LFNoise1.kr(rate, 1, 1)/2];
	signal = Warp1.ar(2, bufnum, Select.kr(playback, point), pitch, wSize, -1, 8, 0.1, 2);
	mix= gate.linlin(0, 1, -1, 1);
	ReplaceOut.ar(out, XFade2.ar(input, signal, mix)) ;
}).writeDefFile(d);
)

(
s.waitForBoot{

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

SynthDef(\playExample, { arg out = 0, bufnum;
    Out.ar( out,
        PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)!2, loop:1)
    )
}).add;




SynthDef.new(\freeze,{
	arg in,out= 0, point= 0, pitch= 1, glide= 0.3, gate= 0, wSize= 0.1, playback= 0, rate= 0.1;
	var bufnum, signal, input, mix;
	input= SoundIn.ar(in,2);
	bufnum= LocalBuf(s.sampleRate*2, 2); // recording 2 seconds
	RecordBuf.ar(input, bufnum, 0, 1, 0, (gate-1).abs, 1, gate);
	point = [Lag.kr(point, glide), LFSaw.kr(rate).abs, SinOsc.kr(rate).abs, LFTri.kr(rate).abs, LFNoise1.kr(rate, 1, 1)/2];
	signal = Warp1.ar(2, bufnum, Select.kr(playback, point), pitch, wSize, -1, 8, 0.1, 2);
	mix= gate.linlin(0, 1, -1, 1);
	ReplaceOut.ar(out, XFade2.ar(input, signal, mix)) ;
}).add;





w= Window("Freeze").setTopLeftBounds(Rect(200, 200, 400, 200)).front;

Button(w, Rect(40, 10, 80, 20))
.states_([["open file"]])
.action_({|v|
	Dialog.openPanel({ arg path;
		path.postln;
		{
		{b.free}.try;
		s.sync;
		b = Buffer.read(s, path);
		}.fork;
	},{
  	  "cancelled".postln;
	});
});

Button(w, Rect(130, 10, 80, 20))
.states_([["play"],["stop"]])
.action_({|v|
	if(v.value == 1, {
		x= Synth(\playExample, [\bufnum, b],  addAction: \addToHead);
		a= Synth(\freeze, addAction: \addToTail);
		},{
		x.free;
		a.free;
	});
});

Button(w, Rect(220, 10, 80, 20))
.states_([["freeze"],["unfreeze"]])
.action_({|v|
	if(v.value == 1,
		{a.set(\gate, 1)},
		{a.set(\gate, 0)});
});

EZSlider(w,
	Rect(0, 40, 400, 20),
	"point",
	ControlSpec(0,1, \lin, 0, 0),
	{|ez| //action
		a.set(\point, ez.value)
		},
	0, // init value
	labelWidth: 40
);

EZSlider(w,
	Rect(0, 60, 400, 20),
	"pitch",
	ControlSpec(0,2, \lin, 0, 1),
	{|ez| //action
		a.set(\pitch, ez.value)
		},
	1, // init value
	labelWidth: 40
);

EZSlider(w,
	Rect(0, 80, 400, 20),
	"glide",
	ControlSpec(0,1, \lin, 0, 0.3),
	{|ez| //action
		a.set(\glide, ez.value)
		},
	0.3, // init value
	labelWidth: 40
);

EZSlider(w,
	Rect(0, 100, 400, 20),
	"grain size",
	ControlSpec(0,1, \lin, 0, 0.3),
	{|ez| //action
		a.set(\wSize, ez.value)
		},
	0.3, // init value
	labelWidth: 40
);

EZPopUpMenu(w, Rect(20, 130, 250, 20),
	"scrub with ugen:",
	["point slider", "LFsaw", "SinOsc", "LFTri", "LFNoise2" ],
	{ |ez|
	a.set(\playback, ez.value);
	ez.value.postln;
	},
	labelWidth: 120
);

EZSlider(w,
	Rect(0, 150, 400, 20),
	"rate",
	ControlSpec(0.01, 5, \exp, 0.01, 0.1),
	{|ez| //action
		a.set(\rate, ez.value)
		},
	0.1, // init value
	labelWidth: 40
);

w.onClose= {b.free; {x.free}.try; {a.free}.try; };

}
)