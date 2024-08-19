// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract AddressChecker {

    // Function to check if an address is a contract
    function isContract(address account) public view returns (bool) {
        uint256 size;
        assembly {
            // Retrieve the size of the code at address account
            size := extcodesize(account)
        }
        // If size is greater than zero, it is a contract
        return size > 0;
    }
}
