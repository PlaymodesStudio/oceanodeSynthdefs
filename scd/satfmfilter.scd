
//a serial HP-LP FM filter with saturation
(
SynthDef.new(\satfmfilter13, {
	arg in=0,out=0;
	var input,filteredHP,filteredLP,inputLPfm,inputHPfm,finalsig;
	var lppitch=\lppitch.kr(90!13).midicps; //0-130
	var lpres=\lpres.kr(0.7!13);
	var hppitch=\hppitch.kr(20!13).midicps;
	var hpres=\hpres.kr(0.7!13);
	var lpfm=\lpfm.kr(0!13); //0-3000
	var hpfm=\hpfm.kr(0!13);
	var drive=\dbdrive.kr(10!13); //0-30db

	input = In.ar(in, 13);

	inputLPfm=input*lpfm; //we use the input also as an FM source
	inputHPfm=input*hpfm;

	filteredHP=BHiPass4.ar(input,hppitch+inputHPfm,hpres,drive.dbamp).tanh;//LP filter and saturation
	filteredLP=BLowPass4.ar(filteredHP,lppitch+inputLPfm,lpres); //HP filtering in series

	finalsig=LeakDC.ar(filteredLP,0.995,drive.dbamp).tanh; //final saturation and dc correction

	Out.ar(out, finalsig);

}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;