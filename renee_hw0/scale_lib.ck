public class ScaleLibrary {
    // Declare arrays (no assignment here!)
    static int major[];
    static int naturalMinor[];
    static int dorian[];
    static int mixolydian[];
    static int lydian[];
    static int phrygian[];
    static int locrian[];
    static int harmonicMinor[];
    static int melodicMinor[];
    static int pentatonic[];
    static int blues[];
    static int diminished7[];
    static int dom7[];

    // Function to get scale by name
    fun int[] getScale(string name) {
        if(name == "major")          return major;
        else if(name == "minor")     return naturalMinor;
        else if(name == "dorian")    return dorian;
        else if(name == "mixolydian")return mixolydian;
        else if(name == "lydian")    return lydian;
        else if(name == "phrygian")  return phrygian;
        else if(name == "locrian")   return locrian;
        else if(name == "harmonicMinor") return harmonicMinor;
        else if(name == "melodicMinor") return melodicMinor;
        else if(name == "pentatonic") return pentatonic;
        else if(name == "blues")     return blues;
        else if(name == "diminished7")return diminished7;
        else if(name == "dom7")      return dom7;
        else return major; // default
    }
}

// Now assign values outside the class declaration:
[0, 2, 4, 5, 7, 9, 11]     @=> ScaleLibrary.major;
[0, 2, 3, 5, 7, 8, 10]     @=> ScaleLibrary.naturalMinor;
[0, 2, 3, 5, 7, 9, 10]     @=> ScaleLibrary.dorian;
[0, 2, 4, 5, 7, 9, 10]     @=> ScaleLibrary.mixolydian;
[0, 2, 4, 6, 7, 9, 11]     @=> ScaleLibrary.lydian;
[0, 1, 3, 5, 7, 8, 10]     @=> ScaleLibrary.phrygian;
[0, 1, 3, 5, 6, 8, 10]     @=> ScaleLibrary.locrian;
[0, 2, 3, 5, 7, 8, 11]     @=> ScaleLibrary.harmonicMinor;
[0, 2, 3, 5, 7, 9, 11]     @=> ScaleLibrary.melodicMinor;
[0, 2, 4, 7, 9]            @=> ScaleLibrary.pentatonic;
[0, 3, 5, 6, 7, 10]        @=> ScaleLibrary.blues;
[0, 3, 6, 9]               @=> ScaleLibrary.diminished7;
[0, 4, 7, 10]              @=> ScaleLibrary.dom7;