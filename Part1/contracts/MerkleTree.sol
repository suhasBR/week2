//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root
    

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
         for(uint i=0;i<15;i++){
            hashes.push(0);
        }

        hashes[8] = PoseidonT3.poseidon([hashes[0],hashes[1]]);
        hashes[9] = PoseidonT3.poseidon([hashes[2],hashes[3]]);
        hashes[10] = PoseidonT3.poseidon([hashes[4],hashes[5]]);
        hashes[11] = PoseidonT3.poseidon([hashes[6],hashes[7]]);

        hashes[12] = PoseidonT3.poseidon([hashes[8],hashes[9]]);
        hashes[13] = PoseidonT3.poseidon([hashes[10],hashes[11]]);

        hashes[14] = PoseidonT3.poseidon([hashes[12],hashes[13]]);

        root = hashes[14];

    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        require(index<8);
        // hashes[index] = hashedLeaf;
        // uint256 a = 1;
        // uint256 b = 2;

        
        // hashes[8] = PoseidonT3.poseidon([a,b]);
        // hashes[12] = PoseidonT3.poseidon([hashes[8],hashes[9]]);
        // hashes[14] = PoseidonT3.poseidon([hashes[12],hashes[13]]);
        
        // root = hashes[14];

        // index++;

        
        //update other elements

        uint next = index;

        if(index%2 == 0){
            hashes[(index/2)+8] = PoseidonT3.poseidon([hashes[index],hashes[index+1]]);
            next = (index/2)+8;
        }
        else{
            hashes[((index-1)/2)+8] = PoseidonT3.poseidon([hashes[index],hashes[index-1]]);
            next = (index-1)/2+8;
        }

        if(next%2 == 0){
            hashes[((next-8)/2)+12] = PoseidonT3.poseidon([hashes[next],hashes[next+1]]);
        }
        else{
            hashes[((next-8-1)/2)+12] = PoseidonT3.poseidon([hashes[next],hashes[next-1]]);
        }

        hashes[14] = PoseidonT3.poseidon([hashes[12],hashes[13]]);

        root = hashes[14];

        index++;
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root

         

         bool check = verifyProof(a, b, c, input);

         bool same = (input[0] == root);

         return same&&check;
    }
}
