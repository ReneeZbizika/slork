@import "constants.ck";
Constants c;

@import "listen.ck";
OSCListener listener;
listener.init(9000);  // match the port set in iDraw OSC

//spork ~ osc_control_loop(players[0]);

// ======================== Granular Synthesis ========================
class Granulator
{
    LiSa lisa;
    PoleZero blocker;
    NRev reverb;
    ADSR adsr;
    Gain master_gain;

    float saved_gain;
    float muted;
    1.0 => float grain_play_rate;       // current playback rate for grains (can be modified by height of cursor)
    
    fun void init(string filepath)
    {
        // set the sample for the LiSa (use one LiSa per sound)
        setSample(filepath);
        
        0.05 => this.reverb.mix;     // reverb mix
        0.99 => this.blocker.blockZero; // pole location to block DC and ultra low frequencies

        this.lisa.chan(0) => this.blocker => this.reverb => this.master_gain => dac;

        spork ~ this.granulate();
        spork ~ this.mouse_listener();

        this.mute();
    }

    fun void setMasterGain(float gin) {
        gin => this.master_gain.gain;
    }

    fun void granulate() {
        while( true ) {
            // fire a grain
            fireGrain();
            // amount here naturally controls amount of overlap between grains
            c.GRAIN_LENGTH[0] / c.GRAIN_OVERLAP + Math.random2f(0,c.GRAIN_FIRE_RANDOM)::ms => now;
        }
    }

    fun void setSample(string filename)
    {
        SndBuf buf;
        buf.read(filename);

        buf.samples()::samp => this.lisa.duration;

        for (int i; i < buf.samples(); i++)
        {
            this.lisa.valueAt(buf.valueAt(i * buf.channels()), i::samp);
        }

        this.lisa.play(false);
        this.lisa.loop(false);
        this.lisa.maxVoices(c.LISA_MAX_VOICES);
    }

    fun void mute() {
        <<< "muting" >>>;
        if (this.lisa.gain() < .01) return;
        this.lisa.gain() => saved_gain;
        0 => this.lisa.gain;
    }

    fun void mute(dur du) {
        <<< "muting" >>>;
        if (this.lisa.gain() < .01) return;
        this.lisa.gain() => saved_gain;
        now + du => time later;
        while (now < later) {
            ((later - now) / du) => this.lisa.gain;
            1::ms => now;
        }
    }

    fun void unmute(dur du) {
        <<< "unmuting" >>>;
        if (this.lisa.gain() > .01) return;
        now + du => time later;
        while (now < later) {
            saved_gain * (1 - ((later - now) / du)) => this.lisa.gain;
            1::ms => now;
        }
    }

    fun void fireGrain()
    {
        c.GRAIN_LENGTH[0] * c.GRAIN_RAMP_FACTOR => dur ramp_time;
        // c.GRAIN_POSITION + Math.random2f(0, c.GRAIN_POSITION_RANDOM) => float pos;
        c.GRAIN_POSITION => float pos;

        if( pos >= 0 )
            spork ~ grain(pos * this.lisa.duration(), c.GRAIN_LENGTH[0], ramp_time, ramp_time,
            grain_play_rate, c.GRAIN_PLAY_RATE_OFF, c.GRAIN_SCALE_DEG);
    }


    fun void grain(dur pos, dur grainLen, dur rampUp, dur rampDown, float rate, float off, float deg )
    {
        // get a voice to use
        this.lisa.getVoice() => int voice;

        // if available
        if( voice > -1 )
        {
            // set rate
            this.lisa.rate( voice, c.RATE_MOD * rate * Math.pow(2, off) * deg ); // TODO: modify rate by offset here
            // set playhead
            this.lisa.playPos( voice, pos );
            // ramp up
            this.lisa.rampUp( voice, rampUp );
            // wait
            (grainLen - rampUp) => now;
            // ramp down
            this.lisa.rampDown( voice, rampDown );
            // wait
            rampDown => now;
        }
    }

    fun void mouse_listener() {
        while (true) {
            // Set grain playback position from X
            Math.remap(x, 0, 800, 0.0, 1.0) => c.GRAIN_POSITION;

            // Set playback rate from Y
            if (y > 0)
                Math.remap(y, 0, 800, 1.0, 4.0) => grain_play_rate;
            else
                Math.remap(y, -800, 0, 0.0, 1.0) => grain_play_rate;

            // Set volume from pressure
            if (pressure > 0.05) {
                spork ~ this.unmute(100::ms);
                pressure * 0.7 => this.master_gain.gain;
            } else {
                spork ~ this.mute(300::ms);
            }

            50::ms => now; // loop every 50ms
        }
    }
}

// ======================== Control Loop ========================
/* fun void osc_control_loop(SoundPlayer player) {
    while (true) {
        // Apply OSC-based control

        // Map x (horizontal position) to grain position
        Math.remap(x, 0, 800, 0.0, 1.0) => c.GRAIN_POSITION;

        // Map y (vertical position) to playback rate
        if (y > 0)
            Math.remap(y, 0, 800, 1.0, 4.0) => player.gran.grain_play_rate;
        else
            Math.remap(y, -800, 0, 0.0, 1.0) => player.gran.grain_play_rate;

        // Control gain/mute with pressure
        if (pressure > 0.05) {
            spork ~ player.gran.unmute(100::ms);
            pressure * 0.7 => player.gran.master_gain.gain;
        } else {
            spork ~ player.gran.mute(300::ms);
        }

        50::ms => now;
    }
} */ 

// ======================== Sound Player ========================

class SoundPlayer {
    Granulator gran;
    SndBuf buf;
    Gain g;
    int mode;

    fun SoundPlayer(string filepath) {
        buf => g => dac;
        buf.read(filepath);
        0 => g.gain;
        gran.init(filepath);
        -1 => mode;
        toggle();
    }

    fun void toggle() {
        (mode + 1) % 3 => mode;

        // Stop mode
        if (mode == 0) {
            gran.setMasterGain(0.0);
            0 => g.gain;
            // <<< "Stopped sound" >>>;
        } 
        
        // Granular mode (needs to be updated)
        else if (mode == 1) {
            gran.setMasterGain(1.0);
            // <<< "Granular mode (playing)" >>>;
        } 
        
        // Loop mode
        else if (mode == 2) {
            gran.setMasterGain(0.0);
            0 => buf.pos;
            1 => buf.loop;
            1 => g.gain;
            // <<< "Loop mode (playing)" >>>;
        }
    }
}

// ======================== Main Control Flow ========================

// ----------------- Global variables -----------------

// Set up the sound players
SoundPlayer players[0];
for (0 => int i; i < c.NUM_SOUNDS; i++) {
    SoundPlayer sp("samples/" + c.WAVS[i]);
    players << sp;
}


// ----------------- Functions -----------------

fun void print_state(int changed_index)
{
    string print_string;
    for (0 => int i; i < c.WAVS.size(); i++) {
        if (i % 4 == 0) "\n" +=> print_string;
        if (i == changed_index) "[" +=> print_string;
        else " " +=> print_string;

        "(" + c.KEYS[i] + ") " + c.WAVS[i] + " on mode " + players[i].mode +=> print_string;

        if (i == changed_index) "]" +=> print_string;
        else " " +=> print_string;

        "   " +=> print_string;

        <<< "master gain:", players[i].gran.master_gain.gain() >>>;
        
    }
    <<< print_string, "" >>>;
}






fun void main()
{
    Hid kb;
    HidMsg msg;

    if( !kb.openKeyboard( c.KEYBOARD_DEVICE ) ) me.exit();
    <<< "keyboard '" + kb.name() + "' ready", "" >>>;

    while (true) {
        kb => now;

        while (kb.recv(msg)) {
            if (msg.isButtonDown()) {
                <<< "Key pressed:", msg.which >>>;
                for (0 => int i; i < c.NUM_SOUNDS; i++) {
                    if (msg.which == c.KEYS_WHICH[i]) {
                        players[i].toggle();
                        print_state(i);

                        // <<< "Key pressed:", msg.which, " → Mode:", players[i].mode >>>;
                    }
                }
            }
        }
    }
}

main();
