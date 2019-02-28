pragma solidity ^0.5.2;

import 'openzeppelin-solidity/math/SafeMath.sol';
import 'openzeppelin-solidity/token/ERC20/ERC20.sol';

contract DelegateERC20 {
    using SafeMath for uint256;
    
    ERC20 private _contractAddress;
    uint constant _neededApprovals = 3;
    uint256 constant _callLifeTime = 300000; //seconds
    uint256 private _transactionNonce = 0;
    
    
    struct Transaction {
        mapping (address => bool) approvers;
        uint amountOfApprovals;
        uint256 timestamp;
        uint arrayIndex;
        
        bytes transaction;
        address executor;
    }
    
    bytes32[] _pendingTransactions;
    mapping (bytes32 => Transaction) private _transactions;
    mapping (address => bool) private _administrators;
    mapping (bytes4 => string) private _functions;
    
    event TransactionCreated(bytes32 transactionId);
    event TransactionCalled(bytes32 transactionId, bool success, bytes data);
    event ApproveReceived(address from, bytes32 transactionId);
    
    ////////////////////////////////////////////////////////////////////////////////////

    function _hasApproved(address approver, bytes32 transactionId) private view returns (bool) {
        return _transactions[transactionId].approvers[approver];
    }

    function hasApproved(address approver, bytes32 transactionId) public view returns (bool) {
        require (_administrators[approver], 'Approver address is not administrator');
        return _hasApproved(approver, transactionId);
    }

    function createTransferTransaction(address to, uint value) public returns (bytes32) {
        //TODO: move signature to string and replace encoding with encodeWithSignature
        bytes4 selector = bytes4(keccak256("transfer(address,uint256)"));
        bytes32 transactionId = keccak256(abi.encodePacked(selector, _transactionNonce, to, value));

        require(_transactions[transactionId].timestamp == 0, 'Transaction already exists');
        
        _transactions[transactionId].timestamp = now;
        _transactions[transactionId].executor = address(_contractAddress);
        _transactions[transactionId].transaction = abi.encodeWithSelector(selector, to, value);
        
        _pendingTransactions.push(transactionId);
        _transactions[transactionId].arrayIndex = _pendingTransactions.length - 1;

        _transactionNonce = _transactionNonce.add(1);
        emit TransactionCreated(transactionId);
        return transactionId;
    }

    function approveTransaction(bytes32 transactionId) public {
        require (_administrators[msg.sender], 'Approver address is not administrator');
        require(_transactions[transactionId].timestamp != 0, 'Transaction isn\'t exist or already performed');
        require((now - _transactions[transactionId].timestamp) <= _callLifeTime, 'Transaction timeout');
        require(!_hasApproved(msg.sender, transactionId), 'Transaction already aporoved');
        
        _transactions[transactionId].approvers[msg.sender] = true;
        _transactions[transactionId].amountOfApprovals = _transactions[transactionId].amountOfApprovals.add(1);
        emit ApproveReceived(msg.sender, transactionId);
        
        if (_transactions[transactionId].amountOfApprovals >= _neededApprovals) {
            (bool success, bytes memory data) = address(_transactions[transactionId].executor).call(_transactions[transactionId].transaction);
            _removePendingTransaction(transactionId);
            _transactions[transactionId].timestamp = 0;
            emit TransactionCalled(transactionId, success, data);
        }
    }
    
    function getPendingTransaction() public view returns (bytes32[] memory) {
        return _pendingTransactions;
    }
    
    function _removePendingTransaction(bytes32 transactionId) private {
        uint index = _transactions[transactionId].arrayIndex;
        _pendingTransactions[index] = _pendingTransactions[_pendingTransactions.length - 1];
        _transactions[_pendingTransactions[index]].arrayIndex = index;
        delete _pendingTransactions[_pendingTransactions.length - 1];
        --_pendingTransactions.length;
    }
    
    function getTransactionInfo(bytes32 transactionId) public view returns (address, bytes memory) {
        return (_transactions[transactionId].executor, _transactions[transactionId].transaction);
    }
    
    function getFunctionName(bytes4 signature) public view returns (string memory) {
        return _functions[signature];
    }
    
    function addAdministrator(address newAdmin) public {
        //create transaction for adding new administrator
    }
    
    function deleteAdministrator(address admin) public {
        //create transaction for deleting administraor
    }
}
