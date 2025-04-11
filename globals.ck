//globals.ck 

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

public class Shared {
    static float pitchX;      // normalized X position [0.0, 1.0]
    static int isPressed;     // 1 = mouse down, 0 = mouse up
    static PitchMap pitchMap; //
}
<<< "globals loaded!" >>>;

