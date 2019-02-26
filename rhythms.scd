("Setup_MIDI.scd").loadRelative;

(

~t1 = Pbind(
	\instrument,\play,
	\buf, d[\b][0],
	\dur, Pseq([2, Rest(2)],inf),
	\amp, 0.4,
	\pan, -0.1
);

~t2 = Pbind(
	\instrument,\play,
	\buf, d[\ch][0],
	\dur, Pseq([Rest(0.5),1,0.5,1,0.5],inf),
	\amp, 0.3,
	\pan, Pwrand([-0.2, -0.1, 0.1,0.2,0.25, 0.3], [1, 2, 3, 3, 2,1].normalizeSum, inf)
);

~t3 = Pbind(
	\instrument,\play,
	\buf, d[\rd][7],
	\dur,Pwrand([0.25, Pbjorklund2(Pwhite(3,5),8,1)/4,Pseq([2],4)],[7,4,1].normalizeSum,inf),
	\amp, 0.125,
	\pan, Pwrand([-0.2, -0.1, 0.1,0.2,0.25, 0.3], [1, 2, 3, 3, 2,1].normalizeSum, inf)
);

~t4 = Pbind(
	\instrument,\play,
	\buf, d[\ch][4],
	\dur, Pseq([0.25,Rest(1),0.5,1], inf),
	\amp, 0.3,
	\pan, Pwrand([-0.2, -0.1, 0.1,0.2,0.25, 0.3], [1, 2, 3, 3, 2,1].normalizeSum, inf)
);

~t5 = Pbind(
	\instrument,\bplaym,
	\buf, d[\s][1],
	\dur, Pseq([Rest(2), 2], inf),
	\amp, 0.4,
	\pan, 0.2
);

~t6 = Pbind(
	\instrument, \play,
	\buf, d[\bell][0],
	\dur, Pseq([1, 0.5, Rest(0.5), 1, Rest(1)], inf),
	\amp, 0.29,
	\pan, Pwrand([-0.2, -0.1, 0.1,0.2,0.25, 0.3], [1, 2, 3, 3, 2,1].normalizeSum, inf)
);

~t7 = Pbind(
	\instrument, \bplay,
	\buf, d[\glitch][4],
	\dur, Pseq([1, Rest(2)], inf),
	\amp, 0.19
);


~midiClock = Pbind(
    \type, \midi,
    \midicmd, \midiClock,
    \midiout, d[\midi],
	\dur, Pseq([1/24], inf),
	\chan, 0
);
~midiPtr = Pbind(
	\type, \midi,
	\midicmd, \songPtr,
	\midiout, d[\midi],
	\chan, 0,
	\songPtr, 0,
	\dur, Pseq([16], inf)
);
)

(
~t1.play();
~t2.play();
~t3.play();
~t4.play();
~t5.play();
~t4.stop();

~midiClock.play();
~midiPtr.play();
)

x = Synth(\robolay, [\in, 0])
x.free
a.set(\freq, 200);
a.set(\harm, 110);
b = Synth(\mesaboogie, [\in, 0])
b.free
s.plotTree

s.record
s.stopRecording