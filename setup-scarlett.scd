(
s.options.numBuffers = 1024 * 16;
s.options.memSize = 8192 * 64;
s.boot;
p=ProxySpace.push(s);
p.makeTempoClock;
b = 60/120;
q = b * 8;
p.clock.tempo=120/60;
p.quant=q;
Task({
    5.wait;
    d = Dictionary.new;
    d.add(\folders -> PathName(thisProcess.nowExecutingPath.dirname +/+ "samples/set").entries);
    for (0, d[\folders].size-1,
        {arg i; d.add(d[\folders][i].folderName.asSymbol -> d[\folders][i].entries.collect({
            arg sf;
            Buffer.read(s,sf.fullPath);
        });
    )});
    ("synthdefs.scd").loadRelative;
    ("fx.scd").loadRelative;
    5.wait;
    StageLimiter.activate;
    MIDIClient.init;
    10.wait;
    //d[\midi] = MIDIOut.newByName("Midi Through", "Midi Through Port-0").latency_(Server.default.latency);
    d[\midisynth] = MIDIOut.newByName("Midi Through", "Midi Through Port-0").latency_(0.2555);
    d[\midi] = MIDIOut.newByName("Scarlett 6i6 USB", "Scarlett 6i6 USB MIDI 1").latency_(0.2555);
    d[\midi].midiClock;
    d[\midi].start;
    d[\midisynth].start;
    //d[\midi].stop;
    3.wait;
    ~midiClock = Pbind(
      \type, \midi,
      \midicmd, \midiClock,
      \midiout, d[\midi],
      \dur, Pseq([1/24], inf),
      \chan, 0
    );
    1.wait;
    ~midiClock.play;
}).start;
)
