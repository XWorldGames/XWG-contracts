// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity 0.6.6;

interface ITortoiseGrade {

    function randomGrade(uint32 randomNumber) external view returns(uint grade, uint skillNumer, uint32 blood, uint32 attack);

}

pragma solidity 0.6.6;

contract Governances is Ownable {

    mapping(address => bool) public governances;

    function addGovernance(address governance) public onlyOwner {
        governances[governance] = true;
    }

    function removeGovernance(address governance) public onlyOwner {
        governances[governance] = false;
    }

    modifier onlyGovernance() {
        require(governances[_msgSender()], "ERC721: caller is not the owner");
        _;
    }

}

pragma solidity 0.6.6;

contract TortoiseGrade is ITortoiseGrade, Governances {

    mapping(uint => uint32[][]) private gradesAttrs;

    function addGradesAttrs(uint grade, uint32[] memory blood, uint32[] memory attack) public onlyGovernance {
        gradesAttrs[grade] = [blood, attack];
    }

    function getGradesAttrs(uint grade) public view returns(uint32[] memory blood, uint32[] memory attack){
        blood = gradesAttrs[grade][0];
        attack = gradesAttrs[grade][1];
    }

    function getBloodAndAttack(uint32 randomNumber, uint grade) public view returns(uint32 blood, uint32 attack) {
        uint32[][] memory bloodAndAttack = gradesAttrs[grade];
        uint32[] memory bloodArr = bloodAndAttack[0];
        uint32[] memory attackArr = bloodAndAttack[1];

        uint32 bloodStart = bloodArr[0];
        uint32 bloodEnd = bloodArr[1];
        uint32 bloodInterval = bloodEnd-bloodStart;
        uint32 bloodNumber = uint32(randomNumber % (bloodInterval+1));
        blood = bloodStart+bloodNumber;

        uint32 attackStart = attackArr[0];
        uint32 attackEnd = attackArr[1];
        uint32 attacInterval = attackEnd-attackStart;
        uint32 attackNumber = uint32(randomNumber % (attacInterval+1));
        attack = attackStart+attackNumber;

    }

    function randomGrade(uint32 randomNumber) public view override returns(uint grade, uint skillNumer, uint32 blood, uint32 attack) {
        uint number = uint(randomNumber % 100);

        if(number < 49) {
            grade = 1;
        } else if(number > 48 && number < 79) {
            grade = 2;
        } else if(number > 78 && number < 94) {
            grade = 3;
        }else if(number > 93 && number < 99) {
            grade = 4;
        } else {
            grade = 5;
        }

        skillNumer = grade-1;

        (blood, attack) = getBloodAndAttack(randomNumber, grade);
    }

}