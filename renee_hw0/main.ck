Machine.add(me.dir() + "scale_lib.ck");      // Make sure this comes before pitchmap
//Machine.add(me.dir() + "pitchmap.ck");    // pitchMap can now access ScaleLibrary

Machine.add(me.dir() + "globals.ck");


Machine.add(me.dir() + "input.ck");

Machine.add(me.dir() + "synth.ck");

1::second => now; // WAIT for state to settle
//Machine.add(me.dir() + "pad.ck");
Machine.add(me.dir() + "ambient.ck");

