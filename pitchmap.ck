// pitchmap.ck
// Quantizes X to notes in a scale
// assumes ScaleLibrary is already loaded

// PitchMap class
public class PitchMap {
    static int root;
    static int majorScale[];

    // Quantize function
    fun int quantize(float x) {
        (x * majorScale.size()) $ int => int index;
        if(index >= majorScale.size()) index - 1 => index;
        return root + majorScale[index];
    }
}

//Declare global instance
PitchMap pitchMap;

//Make scale lib
// DEBUG: how to call from a static class

// Initialize static values
ScaleLibrary.dorian => Shared.pitchMap.scale;
60 => Shared.pitchMap.root;
