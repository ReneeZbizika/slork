Machine.add(me.dir() + "globals.ck");
Machine.add(me.dir() + "input.ck");
Machine.add(me.dir() + "scales.ck");      // Make sure this comes before pitchmap
Machine.add(me.dir() + "pitchmap.ck");    // pitchMap can now access ScaleLibrary

Machine.add(me.dir() + "synth.ck");
//Machine.add(me.dir() + "pad.ck");
Machine.add(me.dir() + "ambient.ck"); // ambient pad