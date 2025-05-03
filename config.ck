public class Config
{
    // ========================= Device configuration =========================

    // Device numbers
    0 => int KEYBOARD_DEVICE;
    1 => int WEBCAM_DEVICE;

    // OSC port
    9000 => int OSC_PORT;

    // Window size
    1280 => float WINDOW_WIDTH_CONSTANT;
    960 => float WINDOW_HEIGHT_CONSTANT;
    0.8 => float SLIDE_SCALE;
    8.71 * SLIDE_SCALE => float SLIDE_WIDTH;
    4.9 * SLIDE_SCALE => float SLIDE_HEIGHT;


    // ========================= Audio configuration =========================

    // Audio files
    15 => int NUM_GRANULATORS;
    15 => int NUM_SOUNDS;

    [
        "ocean_short.wav",      // 1
        "crickets_0.wav",       // 2
        "wind_0.wav",           // 3
        "seagull_0.wav",        // 4
        "sparkle_2.wav",        // 5
        "scary_0.wav",          // 6
        "sail_0.wav",           // 7
        "axe.wav",              // 8
        "hose.wav",             // 9
        "bomb.wav",             // 0

        "fish.wav",             // Z
        "fire.wav",             // X
        "rain.wav",             // C
        "scream.wav",           // V
        "parachute.wav",        // B
    ] @=> string GRANULATOR_WAVS[];


    [
        "unknown.wav",             //
        "unknown.wav",             //
        "unknown.wav",             // 
        "seagull_0.wav",           // R
        "sparkle_2.wav",           // T
        "scary_2.wav",             // Y
        "sail_0.wav",              // U
        "axe.wav",                 // I
        "hose.wav",                // O
        "bomb.wav",                // P

        "fish.wav",                // A
        "fire.wav",                // S
        "rain.wav",                // D
        "scream.wav",              // F
        "parachute.wav",           // G

    ] @=> string SOUND_WAVS[];


    // Granular synthesis parameters
    1.0 => float MAIN_VOLUME;     // overall volume

    [1000::ms, 1000::ms, 1000::ms, 1000::ms, 1000::ms, 1000::ms, 1000::ms, 1000::ms, 
    1000::ms, 1000::ms, 1000::ms, 1000::ms, 1000::ms, 1000::ms, 1000::ms] @=> dur GRAIN_LENGTH[];    // grain duration base

    32 => float GRAIN_OVERLAP;      // how much overlap when firing
    0.5 => float GRAIN_RAMP_FACTOR;  // factor relating grain duration to ramp up/down time
    0.0 => float GRAIN_PLAY_RATE_OFF;
    1.0 => float GRAIN_SCALE_DEG;
    1.0 =>  float RATE_MOD;  // for samples not on "C"

    0.3 => float GRAIN_POSITION;     // grain position (0 start; 1 end)
    0.01 => float GRAIN_POSITION_RANDOM; // grain position randomization
    3.0 => float GRAIN_FIRE_RANDOM; // grain jitter (0 == periodic fire rate)

    30 => int LISA_MAX_VOICES;


    // ========================= Keyboard configuration =========================

    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "Z", "X", "C", "V", "B"] @=> string GRANULATOR_KEYS_STR[];
    [30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 29, 27, 6, 25, 5] @=> int GRANULATOR_KEYS[];

    // future use:  "H", "J", "K", "L" = 11, 13, 14, 15
    
    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "M", "N"] @=> string SOUND_KEYS_STR[];
    [20, 26, 8, 21, 23, 28, 24, 12, 18, 19, 4, 22, 7, 9, 10, 16, 17] @=> int SOUND_KEYS[];

    [0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] @=> int LOOPS[];           // 1 if the sound should play on loop, 0 if it should not


    79 => int GLITCH_KEY;
    80 => int FIX_GLITCH_KEY;


}