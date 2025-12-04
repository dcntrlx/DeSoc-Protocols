// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract P {
    address[] public owners;
    address public o;

    event D(address da);

    constructor() {
        o = msg.sender;

        emit D(o);
    }
}
