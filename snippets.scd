DDWSnippets.put("tempo", "p.clock.tempo=2");
DDWSnippets.put("pseq", "Pseq([4],inf)");
// Effects

DDWSnippets.put("robolay", "
{Out.ar(10, AudioIn.ar(1))}.play(s, addAction:\addToHead)
a = Synth(\robolay, [\in, 10], addAction:\addToTail)
");


// Amps
DDWSnippets.put("flanger", "
(
SynthDef(\\flanger, {arg in, out=0, vol= -20, pregain=10, gain=8, bass_boost=10, eq_b=0.51, eq_m=0.54, eq_h=0.49, rev=0.45, room=0.3, attack=0.002, knee=5, ratio=5, release=0.3, threshold= -18, cabinet=5, cab_bass=0.1, cab_treble=0.3;
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


	arcopizz_eq = HighShelf.ar(BPeakEQ.ar( BPeakEQ.ar( BPeakEQ.ar( BPeakEQ.ar(BPeakEQ.ar(BPeakEQ.ar (BPeakEQ.ar(BPeakEQ.ar( BPeakEQ.ar(BPeakEQ.ar(BPeakEQ.ar(BPeakEQ.ar(BPeakEQ.ar(BPeakEQ.ar(arcopizz, 80, 1, -1), 90, 1, -10), 100, 1, 10),125, 10, -10), 150, 1, 6), 200, 5, 12), 250, 5, -4), 500, 1, 8),600, 3, 5),650, 3, 4),700, 3, 3),750, 1, -3), 800, 1, -8), 850, 1, -8), 4000, 1, -2);
	arcopizz_eq =FaustFlangerMono.ar(arcopizz_eq);
	bmix = FreeVerb.ar(FaustVolume.ar(FaustBassEnhancer.ar(arcopizz_eq, arcopizz_eq, 80, 12), vol), rev, room, 0,2);

	Out.ar(out, bmix!2);

}).add;
)

x.free;
x = Synth(\\flanger, [\\in, 1])
x.set(\\vol, 0)

");

DDWSnippets.put("vox ac30", "
(
// Vox AC30
SynthDef(\\ac30, {arg in, out=0, vol=(-12), pregain=7, gain=8, bass_boost=7, eq_b=0.41, eq_m=0.74, eq_h=0.59, rev=0.45, room=4.5, attack=0.002, knee=5, ratio=5, release=0.3, threshold=16, cabinet=10, cab_bass=0.5, cab_treble=0.4;
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

c = Synth(\\ac30, [\\in, 0])
c.set(\\vol, 20)
");

DDWSnippets.put("arco pizzicato", "
(
// Bass Arco Pizz
SynthDef(\\arcopizz, {arg in, out=0, vol=(-12), pregain=6, gain=8, bass_boost=7, eq_b=0.81, eq_m=0.74, eq_h=0.49, rev=0.65, room=0.3, attack=0.002, knee=5, ratio=5, release=0.3, threshold=18, cabinet=10, cab_bass=0.4, cab_treble=0.3;
	var sig, arcopizz, bmix;
	sig = SoundIn.ar(in);

	arcopizz = FaustCabinetImpulseFormer.ar(
		FaustPeaveyStyle.ar(
			FaustPresenceLevel.ar(
				FaustBassbooster.ar(
					FaustAmpT2.ar(FaustDrive.ar(FaustValve.ar(sig,0.01,1),5), pregain, gain), bass_boost
				)
			), eq_b, eq_m, eq_h
		), cabinet, cab_bass, cab_treble
	);

	bmix = FreeVerb.ar(FaustVolume.ar(FaustBassEnhancer.ar(arcopizz, arcopizz, 190,4), vol), rev, room, 0,1);
	Out.ar(out, bmix!2);
}).add;
)
a = Synth(\\arcopizz, [\\in, 1])
a.set(\\vol, 10)

");

// MIDI Clock

DDWSnippets.put("midi clock", "
(
~midiClock = Pbind(
    \\type, \\midi,
    \\midicmd, \\midiClock,
    \\midiout, d[\\midi],
	\\dur, Pseq([1/24], inf),
	\\chan, 0
);
~midiPtr = Pbind(
	\\type, \\midi,
	\\midicmd, \\songPtr,
	\\midiout, d[\\midi],
	\\chan, 0,
	\\songPtr, 0,
	\\dur, Pseq([16], inf)
);
)

(
~midiClock.play();
~midiPtr.play();
)
");

DDWSnippets.put("midi note","
(
~stick = Pbind(
    \\type, \\midi,
    \\midicmd, \\noteOn,
	\\midiout, d[\\midi],
    \\chan, 1,
	\\midinote, Pseq([60], inf),
	\\dur, Pseq([1], inf),
	\\amp, Pseq([1.0], inf)
);
)

");

// Bass Drum
DDWSnippets.put("bd", "
(
~bd = Pbind(
    \\instrument,\\sampler,
	\\buf, d[\\b][0],
	\\dur, Pseq([4],inf),
	\\amp, 0.4,
	\\pan, 0.1
);
)
");

// Snare
DDWSnippets.put("sn", "
(
~sn = Pbind(
	\\instrument,\\sampler,
	\\buf, d[\\s][0],
	\\dur, Pseq([4],inf),
	\\amp, 0.3,
	\\pan, -0.2
);
)
");

// Stick
DDWSnippets.put("sk", "
(
~sk = Pbind(
	\\instrument,\\sampler,
	\\buf, d[\\sk][0],
	\\dur, Pseq([4],inf),
	\\amp, 0.4,
	\\pan, -0.2
);
)
");


// Closed HiHat
DDWSnippets.put("ch", "
(
~ch = Pbind(
	\\instrument,\\sampler,
	\\buf, d[\\ch][0],
	\\dur, Pseq([4],inf),
	\\amp, 0.3,
	\\pan, -0.25
);
)
");

// Ride
DDWSnippets.put("rd", "
(
~rd = Pbind(
	\\instrument,\\play,
	\\buf, d[\\rd][0],
	\\dur, Pseq([4],inf),
	\\amp, 0.125,
	\\pan, 0.4
);
)
");

// Pwrand
DDWSnippets.put("pwrand", "Pwrand([d[\\bd]], [1].normalizeSum, inf)");

// Pan
DDWSnippets.put("random p", "Pwrand([-0.2, -0.1, 0.1,0.2,0.25, 0.3], [1, 2, 3, 3, 2,1].normalizeSum, inf)");

