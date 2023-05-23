// SPDX-License-Identifier: The Unlicense
pragma solidity >=0.8.8;

struct ERC20Contract {
    string _name;
    string _symbol;
    address _implementation;
    uint8 _decimals;
    bool _initialized;
    uint256 _totalSupply;
    mapping(address => ERC20Owner) _owner;
    uint256 _INITIAL_CHAIN_ID;
    bytes32 _INITIAL_DOMAIN_SEPARATOR;

}

struct ERC20Owner {
    uint256 _balanceOf;
    mapping(address => uint256) _allowance;
    uint256 _nonces;
}

/*//////////////////////////////////////////////////////////////
                     METADATA STORAGE/LOGIC
//////////////////////////////////////////////////////////////*/
function name(ERC20Contract storage erc20Contract) view returns (string memory) {
    return erc20Contract._name;
}

function symbol(ERC20Contract storage erc20Contract) view returns (string memory) {
    return erc20Contract._symbol;
}

function decimals(ERC20Contract storage erc20Contract) view returns (uint8) {
    return erc20Contract._decimals;
}

/*//////////////////////////////////////////////////////////////
                        EIP-2612 STORAGE
//////////////////////////////////////////////////////////////*/

function INITIAL_CHAIN_ID(ERC20Contract storage erc20Contract) view returns (uint256) {
    return erc20Contract._INITIAL_CHAIN_ID;
}

function INITIAL_DOMAIN_SEPARATOR(ERC20Contract storage erc20Contract) view returns (bytes32) {
    return erc20Contract._INITIAL_DOMAIN_SEPARATOR;
}

function nonces(
    ERC20Contract storage erc20Contract, 
    address owner
) view returns (uint256) {
    return erc20Contract._owner[owner]._nonces;
}

/*//////////////////////////////////////////////////////////////
                           CONSTRUCTOR
//////////////////////////////////////////////////////////////*/

function _constructor(
    ERC20Contract storage erc20Contract,
    string memory _name,
    string memory _symbol,
    uint8 _decimals,
    address _implementation
) {
    require(!erc20Contract._initialized, "ALREADY_INITIALIZED");
    erc20Contract._initialized = true;
    erc20Contract._name = _name;
    erc20Contract._symbol = _symbol;
    erc20Contract._decimals = _decimals;
    erc20Contract._implementation = _implementation;

    erc20Contract._INITIAL_CHAIN_ID = block.chainid;
    erc20Contract._INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator(erc20Contract);
}

/*//////////////////////////////////////////////////////////////
                  ERC20 STORAGE
//////////////////////////////////////////////////////////////*/
function totalSupply(
    ERC20Contract storage erc20Contract
) view returns (uint256) {
    return erc20Contract._totalSupply;
}

function balanceOf(
    ERC20Contract storage erc20Contract, 
    address owner
) view returns (uint256) {
    return erc20Contract._owner[owner]._balanceOf;
}

function allowance(
    ERC20Contract storage erc20Contract, 
    address owner,
    address spender
) view returns (uint256) {
    return erc20Contract._owner[owner]._allowance[spender];
}

/*//////////////////////////////////////////////////////////////
                            ERC20 LOGIC
//////////////////////////////////////////////////////////////*/
function approve(
    ERC20Contract storage erc20Contract, 
    address spender, 
    uint256 amount
) returns (bool) {
    erc20Contract._owner[msg.sender]._allowance[spender] = amount;

    return true;
}

function transfer(
    ERC20Contract storage erc20Contract, 
    address to, 
    uint256 amount
) returns (bool) {

    erc20Contract._owner[msg.sender]._balanceOf -= amount;

    // Cannot overflow because the sum of all user
    // balances can't exceed the max uint256 value.
    unchecked {
        erc20Contract._owner[to]._balanceOf += amount;
    }

    return true;
}

function transferFrom(
    ERC20Contract storage erc20Contract, 
    address from, 
    address to, 
    uint256 amount
) returns (bool) {
    uint256 allowed = erc20Contract._owner[from]._allowance[msg.sender]; // Saves gas for limited approvals.
    
    if(allowed != type(uint256).max) erc20Contract._owner[from]._allowance[msg.sender] -= amount;

    erc20Contract._owner[from]._balanceOf -= amount;

    // Cannot overflow because the sum of all user
    // balances can't exceed the max uint256 value.
    unchecked {
        erc20Contract._owner[to]._balanceOf += amount;
    }

    return true;
}

/*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
//////////////////////////////////////////////////////////////*/
function permit(
    ERC20Contract storage erc20Contract,
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
) {
    require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

    // Unchecked because the only math done is incrementing
    // the owner's nonce which cannot realistically overflow.
    unchecked {
        address recoveredAddress = ecrecover(
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(erc20Contract),
                    keccak256(
                        abi.encode(
                            keccak256(
                                "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                            ),
                            owner,
                            spender,
                            value,
                            erc20Contract._owner[owner]._nonces++,
                            deadline
                        )
                    )
                )
            ),
            v,
            r,
            s
        );

        require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

        erc20Contract._owner[recoveredAddress]._allowance[spender] = value;
    }
}

function DOMAIN_SEPARATOR(ERC20Contract storage erc20Contract) view returns (bytes32) {
    return block.chainid == erc20Contract._INITIAL_CHAIN_ID ? erc20Contract._INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator(erc20Contract);
}

function computeDomainSeparator(ERC20Contract storage erc20Contract) view returns (bytes32) {
    return
        keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(erc20Contract._name)),
                keccak256("1"),
                block.chainid,
                erc20Contract._implementation
            )
        );
}

/*//////////////////////////////////////////////////////////////
                    INTERNAL MINT/BURN LOGIC
//////////////////////////////////////////////////////////////*/

function _mint(
    ERC20Contract storage erc20Contract, 
    address to, 
    uint256 amount
) {
    erc20Contract._totalSupply += amount;

    // Cannot overflow because the sum of all user
    // balances can't exceed the max uint256 value.
    unchecked {
        erc20Contract._owner[to]._balanceOf += amount;
    }
}

function _burn(
    ERC20Contract storage erc20Contract, 
    address from, 
    uint256 amount
) {
    erc20Contract._owner[from]._balanceOf -= amount;
    erc20Contract._totalSupply -= amount;
}


using {
    name,
    symbol,
    decimals,
    INITIAL_CHAIN_ID,
    INITIAL_DOMAIN_SEPARATOR,
    nonces,
    _constructor,
    totalSupply,
    balanceOf,
    allowance,
    approve,
    transfer,
    transferFrom,
    permit,
    DOMAIN_SEPARATOR,
    _mint,
    _burn
} for ERC20Contract global;

