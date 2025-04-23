public class Constants
{
    // Device numbers
    1 => int KEYBOARD_DEVICE;

    // Audio files + keys
    8 => int NUM_GRANULATORS;
    9 => int NUM_SOUNDS;

    [
        "ocean_short.wav",      // 1
        "crickets_0.wav",       // 2   maybe use night_background.wav
        "wind_0.wav",           // 3
        "seagull_0.wav",        // 4
        "sparkle_2.wav",        // 5
        "scary_0.wav",          // 6
        "sail_0.wav",           // 7
        "tropical_0.wav",       // 8
    ] @=> string GRANULATOR_WAVS[];


    [
        "unknown.wav",             // 
        "night_background.wav",    // W
        "unknown.wav",             // 
        "seagull_0.wav",           // R
        "sparkle_2.wav",           // T
        "scary_2.wav",             // Y
        "sail_0.wav",              // U
        "tropical_0.wav",          // I
        "unknown.wav",             // 
    ] @=> string SOUND_WAVS[];



    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"] @=> string GRANULATOR_KEYS_STR[];
    [30, 31, 32, 33, 34, 35, 36, 37, 38, 39] @=> int GRANULATOR_KEYS[];

    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"] @=> string SOUND_KEYS_STR[];
    [20, 26, 8, 21, 23, 28, 24, 12, 18, 19] @=> int SOUND_KEYS[];

    [0, 1, 0, 0, 0, 0, 0, 1, 0] @=> int LOOPS[];           // 1 if the sound should play on loop, 0 if it should not
    
    // Granular synthesis parameters
    1.0 => float MAIN_VOLUME;     // overall volume

    [1000::ms, 1000::ms, 1000::ms, 1000::ms, 1000::ms, 1000::ms, 1000::ms, 1000::ms, 1000::ms, 1000::ms] @=> dur GRAIN_LENGTH[];    // grain duration base

    32 => float GRAIN_OVERLAP;      // how much overlap when firing
    0.5 => float GRAIN_RAMP_FACTOR;  // factor relating grain duration to ramp up/down time
    0.0 => float GRAIN_PLAY_RATE_OFF;
    1.0 => float GRAIN_SCALE_DEG;
    1.0 =>  float RATE_MOD;  // for samples not on "C"

    0.3 => float GRAIN_POSITION;     // grain position (0 start; 1 end)
    0.01 => float GRAIN_POSITION_RANDOM; // grain position randomization
    3.0 => float GRAIN_FIRE_RANDOM; // grain jitter (0 == periodic fire rate)

    30 => int LISA_MAX_VOICES;
}