(
SynthDef(\bitdowner, { arg out=0, bits=12, gain=0, vol=0;
    var in, fx;
    in = In.ar(out,2);
    fx= FaustBitDowner.ar(in, bits, gain, vol);
    Out.ar(out, fx);
}, [\ir, 0]).add;

SynthDef(\chorus, { arg out=0, freq=2, level=0.5, wet_dry=100;
    var in, fx;
    in = In.ar(out,2);
    fx= FaustChorusMono.ar(in, freq, level, wet_dry);
    Out.ar(out, fx);
}, [\ir, 0]).add;

SynthDef(\flanger, { arg out=0, level=0, lfobpm=24, wet_dry=100;
    var in, fx;
    in = In.ar(out,2);
    fx= FaustFlangerMono.ar(in, level, lfobpm, wet_dry);
    Out.ar(out, fx);
}, [\ir, 0]).add;

SynthDef(\phaser, { arg out=0, level=0, lfobpm=30, wet_dry=100;
    var in, fx;
    in = In.ar(out,2);
    fx= FaustPhaserMono.ar(in, level, lfobpm, wet_dry);
    Out.ar(out, fx);
}, [\ir, 0]).add;

SynthDef(\ringmodulator, { arg out=0, freq=240, wet_dry=0.5;
    var in, fx;
    in = In.ar(out,2);
    fx= FaustRingModulatorMono.ar(in, dry_wet, freq);
    Out.ar(out, fx);
}, [\ir, 0]).add;

SynthDef(\enhancer, { arg out=0, delay=0, freq=0;
    var in, fx;
    in = In.ar(out,2);
    fx= FaustPanoramEnhancer.ar(in, in, delay, freq);
    Out.ar(out, fx);
}, [\ir, 0]).add;

SynthDef(\platereverb, { arg out=0, bandwidth=0.9, damping=0.0005, decay_diff_1=0.1, decay_diff_2=0.1, decay=0.1, dry_wet=0.5, excursion=0, input_diff_1=0.1, input_diff_2=0.1, predelay=0;
    var in, fx;
    in = In.ar(out,2);
    fx= FaustPlateReverb.ar(in, in, bandwidth, damping, decay_diff_1, decay_diff_2, decay, dry_wet, excursion, input_diff_1, input_diff_2, predelay);
    Out.ar(out, fx);
}, [\ir, 0]).add;
)
