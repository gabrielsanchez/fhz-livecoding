(
SynthDef(\echo, { arg out=0, maxdtime=0.2, dtime=0.2, decay=2, gate=1;
    var env, in;
    env = Linen.kr(gate, 0.05, 1, 0.1, 2);
    in = In.ar(out, 2);
    XOut.ar(out, env, CombL.ar(in * env, maxdtime, dtime, decay, 1, in));
}, [\ir, \ir, 0.1, 0.1, 0]).add;

SynthDef(\distort, { arg out=0, pregain=40, amp=0.2, gate=1;
    var env;
    env = Linen.kr(gate, 0.05, 1, 0.1, 2);
    XOut.ar(out, env, (In.ar(out, 2) * pregain).distort * amp);
}, [\ir, 0.1, 0.1, 0]).add;

SynthDef(\wah, { arg out=0, gate=1;
    var env, in;
    env = Linen.kr(gate, 0.05, 1, 0.4, 2);
    in = In.ar(out, 2);
	in = DelayC.ar(in,0.2,0.5);
    XOut.ar(out, env, RLPF.ar(in, LinExp.kr(LFNoise1.kr(0.3), -1, 1, 200, 8000), 0.1).softclip * 0.8);
}, [\ir, 0]).add;

SynthDef(\bitcrush, { arg out=0, bits=12;
    var audio, efx, f;
    audio = In.ar(out,2);
    efx=  Decimator.ar(audio, SinOsc.ar(0.05, 0, 9000, 1000).abs, bits);
    Out.ar(out, efx);
}, [\ir, 0]).add;

// taken from http://sccode.org/1-4XD
SynthDef(\dissonator, { arg out=0, mix=1.0;
    var filterfreqs = Array.geom(23, 60, 2**(1/3));
    var rq = ((2**(1/3)) - 1) / (2**(1/6));
    var width = 2**(1/6);
    var fmin = filterfreqs / width;
    var fmax = filterfreqs * width;
    var g = { |f| 2.27 * (f**0.477) };
    var snd, mod;
    snd = In.ar(out);
    snd = BPF.ar(snd, filterfreqs, rq);
    mod = SinOsc.ar(0.5 * g.value((0.2*fmin) + (0.8*fmax)));
    mod = (1 - mix) + (mix * mod);
    snd = snd * mod;
    snd = Mix(snd);
    ReplaceOut.ar(out, snd);
}, [\ir, 0]).add;

SynthDef(\rlpf, { arg out=0, freq=400;
    var in;
    in = In.ar(out, 2);
    Out.ar(out, RLPF.ar(in, freq))
}, [\ir, 0]).add;

SynthDef(\lpf, { arg out=0, freq=400;
    var in;
    in = In.ar(out, 2);
    Out.ar(out, LPF.ar(in, freq))
}, [\ir, 0]).add;

SynthDef(\hpf, { arg out=0, freq=400;
    var in;
    in = In.ar(out, 2);
    Out.ar(out, HPF.ar(in, freq))
}, [\ir, 0]).add;

)
