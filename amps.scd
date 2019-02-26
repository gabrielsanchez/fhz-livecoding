
(
// Fender Bassman
SynthDef(\bassman, {arg in, out=0, vol=17, pregain=5, gain=5, disto=0, bass_boost=8, eq_b=0.51, eq_m=0.33, eq_h=0.37, rev=0.1, attack=0.02, knee=6, ratio=3, release=0.3, threshold=20;
	var sig, fender_bassman;
	sig = SoundIn.ar(in);
	fender_bassman = FaustCompressor.ar(
		Pan2.ar(
			FreeVerb.ar(
				FaustVolume.ar(
					FaustCabinetImpulseFormer.ar(
						FaustBassmanStyle.ar(
							FaustPresenceLevel.ar(
								FaustBassbooster.ar(
									FaustAmpT2.ar(
										FaustValve.ar(
											sig, disto
										),
									    pregain, gain
									),
								    bass_boost
								),
							),
							eq_b, eq_m, eq_h
						),
						1,0,0
					),
					vol
				),
				rev
			)
		),
		attack, knee, ratio, release, threshold.neg
	);
	Out.ar(out, fender_bassman);
}).add;

a.free;
a = Synth(\bassman, [\in, 1])
)


(
// Vox AC30
SynthDef(\ac30, {arg in, out=0, vol=0, pregain=7, gain=8, bass_boost=7, eq_b=0.41, eq_m=0.74, eq_h=0.59, rev=0.45, room=4.5, attack=0.002, knee=5, ratio=5, release=0.3, threshold=16, cabinet=10, cab_bass=0.5, cab_treble=0.4;
	var sig, ac30;
	sig = SoundIn.ar(in);
	ac30 = Pan2.ar(
		FreeVerb.ar(
			FaustVolume.ar(
				FaustCabinetImpulseFormer.ar(
					FaustAC30Style.ar(
						FaustPresenceLevel.ar(
							FaustBassbooster.ar(
								FaustAmpT2.ar(FaustValve.ar(sig,0.01,1), pregain, gain), bass_boost
							),
						), eq_b, eq_m, eq_h
					), cabinet, cab_bass, cab_treble
				), vol
			), rev, room
		)
	);
	Out.ar(out, ac30!2);
}).add;
)

c = Synth(\ac30, [\in, 0])
c.set(\vol, 20)
c.free

b = Buffer.alloc(s,2048,1);
x = FFT(b, d[\kt][0])
x = PV_MagSmear(x,10);
x.inspect

(
// Peavey Amp (bass)
SynthDef(\peaveybass, {arg in, out=0, vol= -20, pregain=10, gain=8, bass_boost=10, eq_b=0.51, eq_m=0.54, eq_h=0.49, rev=0.45, room=0.3, attack=0.002, knee=5, ratio=5, release=0.3, threshold= -18, cabinet=5, cab_bass=0.1, cab_treble=0.3;
	var sig, arcopizz, arcopizz_eq, arcopizz_c, bmix, lo, hi;

	sig = SoundIn.ar(in);

	arcopizz = FaustCabinetImpulseFormer.ar(
		FaustPeaveyStyle.ar(
			FaustPresenceLevel.ar(
				FaustBassbooster.ar(
					FaustAmpT2.ar(FaustDrive.ar(FaustValve.ar(HPF.ar(sig,40),0.01,1),1), pregain, gain), bass_boost
				), 3
			), eq_b, eq_m, eq_h
		), cabinet, cab_bass, cab_treble
	);


	lo = LPF.ar(arcopizz, 300);
	hi = HPF.ar(arcopizz, 300);
	lo= (lo * 1.5).tanh;
	//hi = (hi * 1.5).tanh;
	c = HPF.ar(lo+hi, 70);
	//c = Compander.ar(f, f, 0.1, 1, 0.5, 0.005, 0.01);


	// shaper, softclip, tanh
	// weight 80-100Hz
	// boom 100 - 150Hz
	// warmth 100 - 300Hz
	// attack 500 - 1500Hz
	// string noise 2k - 5k



	arcopizz_eq = HighShelf.ar(BPeakEQ.ar( BPeakEQ.ar( BPeakEQ.ar( BPeakEQ.ar(BPeakEQ.ar(BPeakEQ.ar (BPeakEQ.ar(BPeakEQ.ar( BPeakEQ.ar(BPeakEQ.ar(BPeakEQ.ar(BPeakEQ.ar(BPeakEQ.ar(BPeakEQ.ar(arcopizz, 80, 1, -1), 90, 1, -10), 100, 1, 10),125, 10, -10), 150, 1, 6), 200, 5, 12), 250, 5, -4), 500, 1, 8),600, 3, 5),650, 3, 4),700, 3, 3),750, 1, -3), 800, 1, -8), 850, 1, -8), 4000, 1, -2);
	bmix = FreeVerb.ar(FaustVolume.ar(FaustBassEnhancer.ar(arcopizz_eq, arcopizz_eq, 80, 12), vol), rev, room, 0,2);
	Out.ar(out, bmix!2);

}).add;
)

x.free;
x = Synth(\peaveybass, [\in, 1])
x.set(\vol, 0)


s.record
s.stopRecording

(
// Multi-Band Distortion
SynthDef(\mbdistortion, {arg in, out=0, vol=50.1, pregain=10, gain=10, bass_boost=10, eq_b=0.61, eq_m=0.34, eq_h=0.69, rev=0.45, room=0.5, attack=0.002, knee=5, ratio=3, release=0.3, threshold=16, cabinet=10, cab_bass=0.8, cab_treble=0.9, dist_gain=3, drive=0.65, high_drive=1, middle_h_drive=1, middle_l_drive=1, low_drive=1;
	var sig, disto, disto_eq, fin;
	sig = SoundIn.ar(in);
	disto = FaustAntiAlias.ar(
				FaustCabinetImpulseFormer.ar(
					FaustMultiBandDistortion.ar(
						FaustMesaBoogieStyle.ar(
							FaustPresenceLevel.ar(
								FaustBassbooster.ar(
									FaustAmpT2.ar(
										FaustValve.ar(sig,0.01,1),
										pregain, gain
									), bass_boost
								)
							), eq_b, eq_m, eq_h
						), dist_gain, drive, high_drive, middle_h_drive, middle_l_drive, low_drive
					), cabinet, cab_bass, cab_treble
				), 0.4
			);
	disto_eq = FaustEq.ar(disto, 0,-8,-14,-7,-30,-30,-30,10,-40,-40); // gain:-40 a 30 q= 1 a 100

	fin = FaustCompressor.ar(Pan2.ar(FreeVerb.ar(FaustVolume.ar(disto_eq, vol.neg), rev, room)), attack, knee, ratio, release, threshold.neg);
	Out.ar(out, disto!2);
}).add;
)
b.free;
b = Synth(\mbdistortion, [\in, 1])
