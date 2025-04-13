(
~synthCreator.value("EQ5", {|n|
	var lofreq=80, midlofreq=300, midfreq=800, midhifreq=2000, hifreq=4000, band1=0, band2=0, band3=0,band4=0,band5=0;
var width,wet,sig,source,loshw,p1w,p2w,p3w,hisw;


	lofreq=OceanodeParameterLag.ar(\lowshelf, 80, n, 20, 1000, "vf", 1/30, true);
	midlofreq=OceanodeParameterLag.ar(\peak1, 300, n, 20, 20000, "vf", 1/30, true);
	midfreq=OceanodeParameterLag.ar(\peak2, 800, n, 20, 20000, "vf", 1/30, true);
	midhifreq=OceanodeParameterLag.ar(\peak3, 2000, n, 20, 20000, "vf", 1/30, true);
	hifreq=OceanodeParameterLag.ar(\hishelf, 4000, n, 2000, 20000, "vf", 1/30, true);

	band1=OceanodeParameterLag.ar(\lowshelfdb, 0, n, -30, 30, "vf", 1/30, true);
	band2=OceanodeParameterLag.ar(\peak1db, 0, n, -30, 30, "vf", 1/30, true);
	band3=OceanodeParameterLag.ar(\peak2db, 0, n, -30, 30, "vf", 1/30, true);
	band4=OceanodeParameterLag.ar(\peak3db, 0, n, -30, 30, "vf", 1/30, true);
	band5=OceanodeParameterLag.ar(\hishelfdb, 0, n, -30, 30, "vf", 1/30, true);

	loshw=OceanodeParameterLag.kr(\lowshelf_width, 1, n, 0, 1, "vf", 1/30, true);
	p1w=OceanodeParameterLag.kr(\peak1_width, 1, n, 0, 1, "vf", 1/30, true);
	p2w=OceanodeParameterLag.kr(\peak2_width, 1, n, 0, 1, "vf", 1/30, true);
	p3w=OceanodeParameterLag.kr(\peak3_width, 1, n, 0, 1, "vf", 1/30, true);
	hisw=OceanodeParameterLag.kr(\hishelf_width, 1, n, 0, 1, "vf", 1/30, true);

	source = In.ar(OceanodeInput.kr(\in), n);

	wet = BLowShelf.ar(source, lofreq, loshw, band1);
	wet = BPeakEQ.ar(wet, midlofreq, p1w, band2);
	wet = BPeakEQ.ar(wet, midfreq, p2w, band3);
	wet = BPeakEQ.ar(wet, midhifreq, p3w, band4);
	wet = BHiShelf.ar(wet, hifreq, hisw, band5);
	wet.tanh;

	sig = XFade2.ar(source, wet, OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf") * 2 - 1);


	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "5 Band EQ", category: "Effect/EQ");
)