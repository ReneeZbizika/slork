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

// Initialize static values
60 => pitchMap.root; // C4
ScaleLibrary.getScale("dorian") @=> Shared.pitchMap.scale;
