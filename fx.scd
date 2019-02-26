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

SynthDef(\prm_GrainFreeze, {
  |
  inBus = 0, outBus = 0, amp = 1,
  trigRate = 60, grainDur = 0.35, pos = 0.3, rate = 1,
  attackTime = 0.5, decayTime = 0, sustainLevel = 1, releaseTime = 2, gate = 1,
  lowPassCutoff = 7000, highPassCutoff = 100, postDistCutoff = 18000, distAmt = 1
  |

  var input, record, localBuf;
  var grainTrig, granulation, env, lpf, hpf, dist, sig;

  // Record (into a 1 second, mono buffer)
  input = In.ar(inBus, 1);
  localBuf = LocalBuf.new(SampleRate.ir * 1, 1).clear;
  record = RecordBuf.ar(input, localBuf, loop: 0);

  //// Granulate:
  // Random distribution of triggers prevents amplitude modulation artifacts
  grainTrig = Dust.ar(trigRate);
  granulation = GrainBuf.ar(1, grainTrig, grainDur, localBuf, rate, pos);

  // Filter and distort
  lpf = LPF.ar(granulation, lowPassCutoff);
  hpf = HPF.ar(lpf, highPassCutoff);
  dist = (hpf * distAmt).distort;
  dist = LPF.ar(dist, postDistCutoff);

  // Envelope -- delays start until recording has finished
  env = EnvGen.kr(Env.dadsr(1, attackTime, decayTime, sustainLevel, releaseTime), gate, amp, doneAction: 2);
  sig = dist * env;

  // Output
  sig = Out.ar(outBus, sig);
}, [\ir, 0]).add;

SynthDef(\dissonator, {
	|out = 0, mix = 1.0|
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


)
