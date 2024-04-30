(
SynthDef(\feedback, {
  var snd, env, ingain;
  env=\ingain.kr(1); //per controlar entrada de feedback
  snd = SinOsc.ar(60)*env; //hauria de ser audio input enlloc de sin

  snd = snd + LocalIn.ar(1);
  snd = DelayC.ar(snd, 0.2, 18.collect {
		Rand(0.05, 0.2) + (LFNoise2.ar(0.3) * 1e-3) + (LFNoise2.ar(1) * 1e-4)
  });

  snd = Splay.ar(snd); //stereo!
  snd=snd+PitchShift.ar(snd, [0.1,0.2],0.5);
  snd = LeakDC.ar(snd);
  snd = snd.tanh;
  LocalOut.ar(snd.sum);

  snd = snd * env;
  snd = snd * -15.dbamp;
  Out.ar(\out.kr(0), snd);
}).add;
)

Synth(\feedback);

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\feedback, {
  arg out=0, in=0;
var snd, env, ingain;
  env=\ingain.kr(1); //per controlar entrada de feedback
  snd=In.ar(in,1)*env;
  snd = snd + LocalIn.ar(1);
  snd = DelayC.ar(snd, 0.2, 8.collect {
		Rand(0.05, 0.2) + (LFNoise2.ar(0.3) * 1e-3) + (LFNoise2.ar(1) * 1e-4)
  });

  snd = Splay.ar(snd); //stereo!
  snd=snd+PitchShift.ar(snd, [0.1,0.2],\pitchshift.kr(0.5));
  snd = LeakDC.ar(snd);
  snd = snd.tanh*env;
  LocalOut.ar(snd.sum);

  snd = snd;
  snd = snd * -15.dbamp;
  Out.ar(out, snd);
}).writeDefFile(d);
)

//array delaytime
(
SynthDef(\feedbackb, {
  arg out=0, in=0;
  var snd, env, ingain;
	var delaytime=\delaytime.kr(0.05!8);

  env = \ingain.kr(1); // to control feedback input gain
  snd = In.ar(in,1) * env;
  snd = snd + LocalIn.ar(1);

  snd = DelayC.ar(snd, 0.2, delaytime.collect { |dt|
		dt
  });

  snd = Splay.ar(snd); // stereo!
	snd = snd + PitchShift.ar(snd, \grainsize.kr(0.1!2), \pitchshift.kr(0.5!2));
  snd = LeakDC.ar(snd);
  snd = snd.tanh * env;
  LocalOut.ar(snd.sum);

	snd=snd;
  snd = snd * -15.dbamp;
  Out.ar(out, snd);
}).writeDefFile(d);
)

(
SynthDef(\feedback13, {
  arg out=0, in=0;
var snd, env, ingain;
  env=\ingain.kr(1!13); //per controlar entrada de feedback
  //snd=In.ar(in,13);
	snd = SinOsc.ar(60)!13;
  snd = snd + LocalIn.ar(13);
  snd = DelayC.ar(snd, 0.2, 13.collect {
		Rand(0.05, 0.2) + (LFNoise2.ar(0.3) * 1e-3) + (LFNoise2.ar(1) * 1e-4)
  });

	snd=snd+PitchShift.ar(snd, Rand(0.1, 0.2)!13,\pitchshift.kr(0.5))!13;
  snd = LeakDC.ar(snd);
  snd = snd.tanh*env;
  LocalOut.ar(snd);

  snd = snd;
  snd = snd * -15.dbamp;
	snd = Splay.ar(snd);
  Out.ar(out, snd);
}).play();
)