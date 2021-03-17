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

interface ITortoiseRepository {

    function add(uint256 id, uint32[] calldata role, uint grade, uint[] calldata skills, uint fiveElements) external;

    function remove(uint256 id) external;

    function updateRole(uint256 id, uint index, uint32 value) external;

    function get(uint256 id) external view returns(uint32[] memory role, uint grade, uint[] memory skills, uint fiveElement);

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

contract TortoiseRepository is ITortoiseRepository, Governances {

    mapping(uint256 => uint32[]) private roleMapping;
    mapping(uint256 => uint) private gradeMapping;
    mapping(uint256 => uint[]) private skillMapping;
    mapping(uint256 => uint) private fiveElementMapping;

    function add(uint256 id, uint32[] memory role, uint grade, uint[] memory skills, uint fiveElement) public onlyGovernance override {
        roleMapping[id] = role;
        gradeMapping[id] = grade;
        skillMapping[id] = skills;
        fiveElementMapping[id] = fiveElement;
    }

    function updateRole(uint256 id, uint index, uint32 value) public onlyGovernance override {
        uint32[] storage role = roleMapping[id];
        role[index] = value;
    }

    function updateGrade(uint256 id, uint grade) public onlyGovernance {
        gradeMapping[id] = grade;
    }

    function updateSkill(uint256 id, uint index, uint16 value) public onlyGovernance {
        uint[] storage skills = skillMapping[id];
        skills[index] = value;
    }

    function updateFiveElements(uint256 id, uint fiveElement) public onlyGovernance {
        fiveElementMapping[id] = fiveElement;
    }

    function remove(uint256 id) public onlyGovernance override {
        delete roleMapping[id];
        delete gradeMapping[id];
        delete skillMapping[id];
        delete fiveElementMapping[id];
    }

    function get(uint256 id) public view override returns(uint32[] memory role, uint grade, uint[] memory skills, uint fiveElement) {
       role = roleMapping[id];
       grade =  gradeMapping[id];
       skills = skillMapping[id];
       fiveElement = fiveElementMapping[id];
    }

}