//globals.ck 

// PitchMap class
public class PitchMap {
    static int root;
    static int scale[];

    // Quantize function
    fun int quantize(float x) {
        (x * scale.size()) $ int => int index;
        if(index >= scale.size()) index - 1 => index;
        return root + scale[index];
    }
}

public class Shared {
    static float pitchX;      // normalized X position [0.0, 1.0]
    static int isPressed;     // 1 = mouse down, 0 = mouse up
    static PitchMap pitchMap; //
}
<<< "globals loaded!" >>>;

ScaleLibrary.major @=> Shared.pitchMap.scale;

