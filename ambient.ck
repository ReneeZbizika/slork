// ambient.ck - All-in-one ambient synthscape triggered by trackpad press

// Requires: Shared.isPressed set by input.ck

//1 => Shared.isPressed;  // force on to test audio
// <<< "ambient sees isPressed:", Shared.isPressed >>>;
/* 
while (true) {
    <<< "PAD sees pressed:", Shared.isPressed >>>;
    1::second => now;
}
*/

// --- Layer 1: Modern Pad ---
fun void modernPad()
{
    TriOsc s1 => LPF f1 => Gain g1 => JCRev rev1 => Pan2 p1 => dac;
    TriOsc s2 => LPF f2 => Gain g2 => JCRev rev2 => Pan2 p2 => dac;

    0 => g1.gain => g2.gain;
    850 => f1.freq;
    830 => f2.freq;
    -0.2 => p1.pan;
    0.2 => p2.pan;
    0.2 => rev1.mix => rev2.mix;

    60 => int baseNote;
    Std.mtof(baseNote) * 0.997 => s1.freq;
    Std.mtof(baseNote) * 1.003 => s2.freq;

    SinOsc lfo1 => blackhole;
    SinOsc lfo2 => blackhole;
    0.01 => lfo1.freq;
    0.008 => lfo2.freq;

    spork ~ fadePad(g1, g2, 0.15);

    while (true)
    {
        (lfo1.last() * 80 + 850) => f1.freq;
        (lfo2.last() * 70 + 830) => f2.freq;
        20::ms => now;
    }
}

// --- Layer 2: Gritty Sub Bass ---
fun void subBass()
{
    PulseOsc sub => LPF f => Gain g => dac;
    0.4 => sub.width;
    40 => sub.freq;
    0 => g.gain;
    180 => f.freq;

    spork ~ fadeGain(g, 0.25);

    while (true) 100::ms => now;
}

// --- Layer 3: Airy Top Layer (dual-panned) ---
fun void airLayer()
{
    Noise n1 => BPF f1 => JCRev r1 => Pan2 p1 => Gain g1 => dac;
    8000 => f1.freq;
    1000 => f1.Q;
    0.7 => r1.mix;
    -0.5 => p1.pan;
    0 => g1.gain;

    Noise n2 => BPF f2 => JCRev r2 => Pan2 p2 => Gain g2 => dac;
    8500 => f2.freq;
    900 => f2.Q;
    0.7 => r2.mix;
    0.5 => p2.pan;
    0 => g2.gain;

    spork ~ fadeGain(g1, 0.03);
    spork ~ fadeGain(g2, 0.03);

    while (true) 100::ms => now;
}

// --- Layer 4: Drone with LFO sweep ---
fun void drone()
{
    TriOsc d => LPF f => Gain g => JCRev r => dac;
    Std.mtof(48) => d.freq;
    0 => g.gain;
    700 => f.freq;
    0.3 => r.mix;

    SinOsc lfo => blackhole;
    0.005 => lfo.freq;

    spork ~ fadeGain(g, 0.1);

    while (true)
    {
        (lfo.last() * 100 + 700) => f.freq;
        10::ms => now;
    }
}

// --- Shared fade logic ---
fun void fadeGain(Gain g, float target)
{
    while (true)
    {
        if (Shared.isPressed)
        {
            if (g.gain() < target) g.gain() + 0.01 => g.gain;
        }
        else
        {
            if (g.gain() > 0.0) g.gain() - 0.01 => g.gain;
        }
        50::ms => now;
    }
}

fun void fadePad(Gain g1, Gain g2, float target)
{
    while (true)
    {
        if (Shared.isPressed)
        {
            if (g1.gain() < target) g1.gain() + 0.01 => g1.gain;
            if (g2.gain() < target) g2.gain() + 0.01 => g2.gain;
        }
        else
        {
            if (g1.gain() > 0.0) g1.gain() - 0.01 => g1.gain;
            if (g2.gain() > 0.0) g2.gain() - 0.01 => g2.gain;
        }
        50::ms => now;
    }
}

// --- Launch all layers ---
spork ~ modernPad();
spork ~ subBass();
spork ~ airLayer();
spork ~ drone();

// --- Keep time running ---
while (true) 1::second => now;
