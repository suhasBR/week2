pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/switcher.circom";


template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    
    //initiate array to store the hashes
    var len = 2**n;
    var hash_arr[2**(n+1)-1];

    //copy initial 2**n hashes from leaves signal to hash_arr
    for(var i=0; i<2**n; i++){
        hash_arr[i] = leaves[i];
    }

    /*
    number of times we would run hash function for an input of 2**n leaves 
    would be:
    for a tree with 4 leaves (n=2) ; we would run hash function for 2+1 times
    for a tree with 8 leaves (n=3) ; we would run hash function for 4+2+1 times
    .
    .
    for a tree with n leaves ; we would run hash function for 2**n-1 times
    therefore, initialize posiedon hash array with that many elements
    */
    var total = 2**n-1;
    component poseidon[total];
    var counter = 0;

    //generate merkle tree
    var offset = 0;
    
    while(len>0){//loop stops when len = 0 which is the root
        for(var i=0;i<len-1;i=i+2){
            poseidon[counter] = Poseidon(2);

            poseidon[counter].inputs[0] <== hash_arr[offset+i];
            poseidon[counter].inputs[1] <== hash_arr[offset+i+1];
            hash_arr[offset+len+(i/2)] <== poseidon[counter].out;
            counter++;
        }
        offset = offset + len;
        len = len / 2;
    }

    //last element is the merkle root
    root <== hash_arr[2**(n+1)-1];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path

    component poseidon[n];

    //initiating Switcher to identify whether the node is on the left or right
    component switching[n];

    for(var i=0;i<n;i++){
        switching[i] = Switcher();
        switching[i].L <== i == 0 ? leaf : poseidon[i - 1].out;
        switching[i].R <== path_elements[i];
        switching[i].sel <== path_index[i];

        poseidon[i] = Poseidon(2);
        poseidon[i].inputs[0] <== switching[i].outL;
        poseidon[i].inputs[1] <== switching[i].outR;
    }

    root <==  poseidon[n-1].out;
}