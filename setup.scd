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
    3.wait;
    d = Dictionary.new;
    d.add(\folders -> PathName(thisProcess.nowExecutingPath.dirname +/+ "samples/set").entries);
    for (0, d[\folders].size-1,
        {arg i; d.add(d[\folders][i].folderName.asSymbol -> d[\folders][i].entries.collect({
            arg sf;
            Buffer.read(s,sf.fullPath);
        });
    )});
    ("synthdefs.scd").loadRelative;
    //("snippets.scd").loadRelative;
    ("fx.scd").loadRelative;
    3.wait;
    StageLimiter.activate;
    MIDIClient.init;
    d[\midisynth] = MIDIOut.newByName("Midi Through", "Midi Through Port-0").latency_(0.2555);
    d[\midisynth].start;
}).start;
)
