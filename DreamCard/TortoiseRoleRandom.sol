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

interface ITortoiseRoleRandom {

    function randomRoleName(uint32 randomNumber) external view returns(uint32);

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

contract TortoiseRoleRandom is ITortoiseRoleRandom, Governances {

    uint16 public roleNumber;
    uint32 public totalWeight;
    mapping(uint32 => uint16) public roleRateMapping;

    constructor() public {
        roleNumber = 40;
        totalWeight = 1000;
    }

    function setRoleNumber(uint16 number) external onlyGovernance {
        roleNumber = number;
    }

    function setTotalWeight(uint16 number) external onlyGovernance {
        totalWeight = number;
    }

    function addRoleRate(uint32 name, uint16 roleRate) public onlyGovernance {
        roleRateMapping[name] = roleRate;
    }

    function getRoleRate(uint32 name) public view returns(uint16) {
        return roleRateMapping[name];
    }

    function randomRoleName(uint32 randomNumber) public view override returns(uint32) {
        uint32 number = randomNumber % totalWeight;

        uint32 start = 0;
        for(uint16 index =0; index < roleNumber; index++) {
            uint32 end = start+roleRateMapping[index];
            if(number>= start && number < end) {
                return index;
            }
            start = end;
        }

        return 0;
    }

}