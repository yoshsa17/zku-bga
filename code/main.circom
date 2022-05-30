pragma circom 2.0.3;    // specify the circom compiler version

template Multiplier2(){ // create generic circuit Multiplier2
   signal input in1;    // define input signal in1
   signal input in2;    // define input signal in2
   signal output out;   // define output signal out
   out <== in1 * in2;   // assign in1 * in2 to out and generate constraints
   log(out);            // print signal out
}

component main {public [in1,in2]} = Multiplier2(); // define Multiplier2 circuit and receive input signals

/* INPUT = {
    "in1": "222",
    "in2": "100"
} */