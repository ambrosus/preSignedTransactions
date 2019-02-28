pragma solidity ^0.5.2;

import 'openzeppelin-solidity/math/SafeMath.sol';
import 'openzeppelin-solidity/token/ERC20/ERC20.sol';


/**
 * @title DelegateERC20 smart contract
 * @dev Controls execution of ERC20 token transactions
*/
contract DelegateERC20 {
    using SafeMath for uint256;
    
    ERC20 private _contractAddress;             //address of controlled contract
    uint constant _neededApprovals = 3;         //amount of approves needed for transaction execution
    uint256 constant _callLifeTime = 300000;    //transaction lifetime in seconds
    uint256 private _transactionNonce = 0;
    
    
    struct Transaction {
        mapping (address => bool) approvers;
        uint amountOfApprovals;
        uint256 timestamp;
        uint arrayIndex;    //index in array of pending transactions
        
        bytes transaction;  //function selector + encoded arguments
        address executor;   //contract, that should perform call
    }
    
    bytes32[] _pendingTransactions;
    mapping (bytes32 => Transaction) private _transactions;
    mapping (address => bool) private _administrators;
    mapping (bytes4 => string) private _functions;  // with this we can find function name and signature from selector
    
    event TransactionCreated(bytes32 transactionId);                            //new transaction created
    event TransactionCalled(bytes32 transactionId, bool success, bytes data);   //received needed amount of approvals and transaction executed
    event ApprovalReceived(address from, bytes32 transactionId);                //received approval
    
    ////////////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Checks is account approved transaction
     * @param approver Address of account
     * @param transactionId Identifier of transaction
     * @return true if approver approved transaction with transactionId, and false if not
     */
    function _hasApproved(address approver, bytes32 transactionId) internal view returns (bool) {
        return _transactions[transactionId].approvers[approver];
    }

    /**
     * @dev Checks is account approved transaction
     * @param approver Address of account
     * @dev approver must have permission for approving
     * @param transactionId Identifier of transaction
     * @return true if approver approved transaction with transactionId, and false if not
     */
    function hasApproved(address approver, bytes32 transactionId) public view returns (bool) {
        require (_administrators[approver], 'Approver address is not administrator');
        return _hasApproved(approver, transactionId);
    }

    /**
     * @dev Example of creating transaction, that should be approved by multiple users
     * params of that function is parameters that needed for transaction after all approves is received
     * in this example transaction of tokens should be approved, so we need address of receiver and amount of tokens
     * for any function that should be approved by multiple users, should be created own function that
     * will select executor, add needed function selector and encode parameters
     *
     * @param to Address of receiver
     * @param value Amount of tokens to send
     * @return identifier of new transaction that should be approved
     */
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

    /**
     * @dev Function for approving transaction, if this is last needed approval that executes transaction
     * Reverts if sender hasn't permission to approve transaction, transaction isn't exists or already performed,
     * transaction timeout or transaction already approved
     *
     * @param transactionId Identifier of transaction to approve
     */
    function approveTransaction(bytes32 transactionId) public {
        require (_administrators[msg.sender], 'Approver address is not administrator');
        require(_transactions[transactionId].timestamp != 0, 'Transaction isn\'t exist or already performed');
        require((now - _transactions[transactionId].timestamp) <= _callLifeTime, 'Transaction timeout');
        require(!_hasApproved(msg.sender, transactionId), 'Transaction already aporoved');
        
        _transactions[transactionId].approvers[msg.sender] = true;
        _transactions[transactionId].amountOfApprovals = _transactions[transactionId].amountOfApprovals.add(1);
        emit ApprovalReceived(msg.sender, transactionId);
        
        if (_transactions[transactionId].amountOfApprovals >= _neededApprovals) {
            (bool success, bytes memory data) = address(_transactions[transactionId].executor).call(_transactions[transactionId].transaction);
            _removePendingTransaction(transactionId);
            _transactions[transactionId].timestamp = 0;
            emit TransactionCalled(transactionId, success, data);
        }
    }

    /**
     * @dev Function for obtaining pending transactions
     * @return array with pending transaction identifiers
     */
    function getPendingTransaction() public view returns (bytes32[] memory) {
        return _pendingTransactions;
    }

    /**
     * @dev Internal function for removing transaction from list of pending transactions
     * @dev Replaces transaction with given identifier with last transaction from array of pending transactions
     * @param transactionId Identifier of transaction to remove
     */
    function _removePendingTransaction(bytes32 transactionId) internal {
        uint index = _transactions[transactionId].arrayIndex;
        _pendingTransactions[index] = _pendingTransactions[_pendingTransactions.length - 1];
        _transactions[_pendingTransactions[index]].arrayIndex = index;
        delete _pendingTransactions[_pendingTransactions.length - 1];
        --_pendingTransactions.length;
    }

    /**
     * @dev Function for obtaining pending transaction details
     * @param transactionId Identifier of transaction
     * @return address of contract, that should execute transaction and encoded function selector and parameters
     */
    function getTransactionInfo(bytes32 transactionId) public view returns (address, bytes memory) {
        return (_transactions[transactionId].executor, _transactions[transactionId].transaction);
    }

    /**
     * @dev Function for obtaining function name and parameters from it signature
     * @param signature signature of function
     * @return string with function name and parameters
     */
    function getFunctionName(bytes4 signature) public view returns (string memory) {
        return _functions[signature];
    }

    /**
     * @dev Function for creating transaction for adding new administrator
     * @param newAdmin Address that will be added to administrators list
     */
    function addAdministrator(address newAdmin) public {
        //create transaction for adding new administrator
    }

    /**
     * @dev Function for creating transaction for removing new administrator
     * @param admin Address that will be deleted from administrators list
     */
    function deleteAdministrator(address admin) public {
        //create transaction for deleting administraor
    }
}
