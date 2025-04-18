OscRecv recv;
6449 => recv.port;
recv.listen();

OscEvent oe;
recv.event("/xy1/x") @=> oe;

while (true) {
    oe => now;
    while (oe.nextMsg()) {
        oe.getFloat() => float x;
        <<< "Received X value from iPad:", x >>>;
    }
}

