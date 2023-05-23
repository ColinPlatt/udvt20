// SPDX-License-Identifier: The Unlicense
pragma solidity 0.8.19;

import "src/udvt20.sol";

contract MockUDVTToken {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    ERC20Contract public erc20Contract;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        erc20Contract._constructor(_name, _symbol, _decimals, address(this));
    }

    function mint(address to, uint256 amount) public {
        emit Transfer(address(0), to, amount);
        return erc20Contract._mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        emit Transfer(from, address(0), amount);
        return erc20Contract._burn(from, amount);
    }

    function name() public view returns (string memory) {
        return erc20Contract.name();
    }

    function symbol() public view returns (string memory) {
        return erc20Contract.symbol();
    }

    function decimals() public view returns (uint8) {
        return erc20Contract.decimals();
    }

    function totalSupply() public view returns (uint256) {
        return erc20Contract.totalSupply();
    }

    function balanceOf(address owner) public view returns (uint256) {
        return erc20Contract.balanceOf(owner);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return erc20Contract.allowance(owner, spender);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        emit Approval(msg.sender, spender, amount);
        return erc20Contract.approve(spender, amount);
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        emit Transfer(msg.sender, to, amount);
        return erc20Contract.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        emit Transfer(from, to, amount);
        return erc20Contract.transferFrom(from, to, amount);
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        emit Approval(owner, spender, value);
        return erc20Contract.permit(owner, spender, value, deadline, v, r, s);
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return erc20Contract.DOMAIN_SEPARATOR();
    }

    function nonces(address owner) public view returns (uint256) {
        return erc20Contract.nonces(owner);
    }


}
