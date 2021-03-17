// SPDX-License-Identifier: MIT

pragma solidity 0.6.6;

interface ITortoiseFiveElements {

    function randomFiveElements(uint32 randomNumber) external view returns(uint);

}

pragma solidity 0.6.6;

contract TortoiseFiveElements is ITortoiseFiveElements {

    function randomFiveElements(uint32 randomNumber) public view override returns(uint) {
        uint number = uint(randomNumber % 100);

        if(number < 20) {
            return 1;
        }
        if(number > 19 && number < 40) {
            return 2;
        }
        if(number > 39 && number < 60) {
            return 3;
        }
        if(number > 59 && number < 80) {
            return 4;
        }

        return 5;
    }

}