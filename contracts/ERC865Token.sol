/**
 * Copyright 2019 Ambrosus Inc.
 * Email: tech@ambrosus.com
 */

pragma solidity ^0.5.0;

import 'openzeppelin-solidity/ownership/Ownable.sol';
import 'openzeppelin-solidity/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/token/ERC20/ERC20Detailed.sol';


/**
 * @title ERC865Token smart contract
 * @dev Allows delegating fees for transfers of tokens
 */
contract ERC865Token is ERC20, ERC20Detailed, Ownable {
    mapping (address => uint256) private _nonces;

    /**
     * @dev Ownership and the initial supply of tokens are transferred to `_owner` during creation.
     * So `msg.sender` is not necessarily the `_owner` of the new smart contract.
     */
    constructor (address _owner, string memory _symbol, string memory _name, uint8 _decimals, uint _initialSupply)
        public
        Ownable()
        ERC20Detailed(_name, _symbol, _decimals) {
            _mint(_owner, _initialSupply);
        }
    
    /**
    * @dev Transfer token for a specified address
    * Called by a third party to execute a transfer (similar to transfer from, but using a signature)
    * @param _signature Signed hash of the transfer parameters.
    * @param _from The address which you want to send tokens from.
    * @dev _signature must be produced using the private key of the _from account.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    * @param _nonce The nonce of this transfer.
    * @dev _nonce values must never repeat. To get the current nonce use `getAccountNonce` function.
    */
    function transferPreSigned(bytes memory _signature, address _from, address _to, uint256 _value, uint256 _nonce)
        public
        onlyOwner {
            require(_nonces[_from] == _nonce);
            bytes32 message = keccak256(abi.encodePacked(_from, _to, _value, _nonce));
            require(recoverSigner(message, _signature) == _from);

            _nonces[_from] += 1;
            _transfer(_from, _to, _value);
        }

    /**
     * @return The current account nonce.
     */
    function getAccountNonce(address _account) 
        public 
        view 
        returns (uint256) {
            return _nonces[_account];
        }

    /**
     * @dev Internal function to parse signature parameters from a byte array.
     */
    function splitSignature(bytes memory _signature)
        internal
        pure
        returns (uint8, bytes32, bytes32) {
            require(_signature.length == 65);

            bytes32 r;
            bytes32 s;
            uint8 v;

            assembly {
                // first 32 bytes, after the length prefix
                r := mload(add(_signature, 32))
                // second 32 bytes
                s := mload(add(_signature, 64))
                // final byte (first byte of the next 32 bytes)
                v := byte(0, mload(add(_signature, 96)))
            }

            return (v, r, s);
        }

    /**
     * @dev Internal function to recover signature address. Uses erecover to check the signature.
     */
    function recoverSigner(bytes32 message, bytes memory _signature)
        internal
        pure
        returns (address) {
            uint8 v;
            bytes32 r;
            bytes32 s;

            (v, r, s) = splitSignature(_signature);

            return ecrecover(message, v, r, s);
        }
}

