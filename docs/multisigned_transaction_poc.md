
# DelegateAdminContract

## DelegateERC20 smart contract

For each function that should be approved by several users should be used 2 functions.
One function should encode parameters, set function selector, address of contract that will execute transaction and timestamp.
For each controlled transaction should be created own function for collecting info about that transaction.
After everything is set that function will return transaction id, that can be used for transaction approving.
Example is [transferOwnershipOfControlledContract](#function-transferownershipofcontrolledcontract) or [setControlledContractMultisigned](#function-setcontrolledcontractmultisigned).
Identifiers of all pending transaction are stored in _pendingTransactions array.

The second function is a universal function for transaction approving. With transaction identifier it can add approve for the transaction, and when needed amount of approves received it will execute transaction.
In this contract approving implemented in [approveTransaction()](#function-approvetransaction).

#### Example
Developer Bob wants to transfer ownership of controlled smart contract.
Administrators Vlad, Angel and Antoni uses "Network Management tool"
1. Bob calls function transferOwnershipOfControlledContract() and passes address of new owner.
2. That function creates new transaction and "Network Management Tool" detects that and shows it.
3. Angel and Antony approves transaction clicking on some button, which calls approveTransaction() with transaction identifier.
4. After receiving required amount of approves transaction will be automatically executed.

#### [Contract functions:](#functions)
  * [hasApproved](#function-hasapproved)
  * [getPendingTransaction](#function-getpendingtransaction)
  * [setControlledContract](#function-setcontrolledcontract)
  * [getTransactionInfo](#function-gettransactioninfo)
  * [getFunctionName](#function-getfunctionname)
  * [renounceOwnership](#function-renounceownership)
  * [getControlledContract](#function-getcontrolledcontract)
  * [owner](#function-owner)
  * [approveTransaction](#function-approvetransaction)
  * [transferOwnershipOfControlledContract](#function-transferownershipofcontrolledcontract)
  * [addAdministrator](#function-addadministrator)
  * [deleteAdministrator](#function-deleteadministrator)
  * [setControlledContractMultisigned](#function-setcontrolledcontractmultisigned)
  * [transferOwnership](#function-transferownership)

#### [Contract events:](#events)
  * [TransactionCreated](#event-transactioncreated)
  * [TransactionCalled](#event-transactioncalled)
  * [ApprovalReceived](#event-approvalreceived)
  * [OwnershipRenounced](#event-ownershiprenounced)
  * [OwnershipTransferred](#event-ownershiptransferred)

---

## Functions

### *function* hasApproved

DelegateAdminContract.hasApproved(approver, transactionId) `view` `066997ff`

> Checks is account approved transaction
The approver must have permission for approving

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | approver | Address of account |
| *bytes32* | transactionId | Identifier of transaction |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* |  | undefined |

---

### *function* getPendingTransaction

DelegateAdminContract.getPendingTransaction() `view` `32a85b3e`

> Returns array of pending transactions identifiers



Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32[]* |  | undefined |

---

### *function* setControlledContract

DelegateAdminContract.setControlledContract(newContractAddress) `nonpayable` `3a6fd4bf`

> Setting controlled contract address
 This is a helper for setControlledContractMultisigned, as setting new controlled contract should be approved by multiple users.
 It should be private, but in that case it couldn't be called with low-level call() function. So there is workaround,
 this function is public, but can be called only by contract owner, and ownership is transferred to this contract in the constructor.
 This workaround will be used for every function of contract that should be approved by multiple users.

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | newContractAddress | Address of new controlled contract


---

### *function* getTransactionInfo

DelegateAdminContract.getTransactionInfo(transactionId) `view` `49e6b62c`

> Function for obtaining pending transaction details.
Returns execution status and output parameters if any.

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | transactionId | Identifier of transaction

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *address* |  | undefined |
| *bytes* |  | undefined |

---

### *function* getFunctionName

DelegateAdminContract.getFunctionName(signature) `view` `606329a9`

> Can return function name and parameters from it signature

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes4* | signature | signature of function

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *string* |  | undefined |

---

### *function* renounceOwnership

DelegateAdminContract.renounceOwnership() `nonpayable` `715018a6`

Renouncing to ownership will leave the contract without an owner.
It will not be possible to call the functions with the `onlyOwner` modifier anymore.


> Allows the current owner to relinquish control of the contract.




---

### *function* getControlledContract

DelegateAdminContract.getControlledContract() `view` `79859183`

> Function for getting current controlled contract




---

### *function* owner

DelegateAdminContract.owner() `view` `8da5cb5b`





---

### *function* approveTransaction

DelegateAdminContract.approveTransaction(transactionId) `nonpayable` `8f4fde9f`

> Approving transaction. If this is a last needed approval that executes transaction.
 Reverts if sender hasn't permission to approve transaction, transaction isn't exists or already performed,
 transaction timeout or transaction already approved
 

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | transactionId | Identifier of transaction to approve



---

### *function* transferOwnershipOfControlledContract

DelegateAdminContract.transferOwnershipOfControlledContract(newOwner) `nonpayable` `a5f64627`

> Multisigned ownership transfer of controlled contract
 

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | newOwner | New owner of controlled contract


Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* |  | undefined |

---

### *function* addAdministrator

DelegateAdminContract.addAdministrator(newAdmin) `nonpayable` `c9991176`

> Creating transaction for adding new administrator

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | newAdmin | Address that will be added to administrators list |


---

### *function* deleteAdministrator

DelegateAdminContract.deleteAdministrator(admin) `nonpayable` `dc7154cb`

> Creating transaction for removing new administrator

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | admin | Address that will be deleted from administrators list |


---

### *function* setControlledContractMultisigned

DelegateAdminContract.setControlledContractMultisigned(newContractAddress) `nonpayable` `e36fdd0e`

> Creating transaction for setting controlled contract address. Should be approved by multiple users
 

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | newContractAddress | New address of controlled contract |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* |  | undefined |

---

### *function* transferOwnership

DelegateAdminContract.transferOwnership(_newOwner) `nonpayable` `f2fde38b`

> Allows the current owner to transfer control of the contract to a newOwner.

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | _newOwner | The address to transfer ownership to. |

---
## Events

### *event* TransactionCreated

DelegateAdminContract.TransactionCreated(transactionId) `ee4f8d3f`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | transactionId | not indexed |

---

### *event* TransactionCalled

DelegateAdminContract.TransactionCalled(transactionId, success, data) `af6332bc`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | transactionId | not indexed |
| *bool* | success | not indexed |
| *bytes* | data | not indexed |

---

### *event* ApprovalReceived

DelegateAdminContract.ApprovalReceived(from, transactionId) `6834fb10`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | from | not indexed |
| *bytes32* | transactionId | not indexed |

---

### *event* OwnershipRenounced

DelegateAdminContract.OwnershipRenounced(previousOwner) `f8df3114`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | previousOwner | indexed |

---

### *event* OwnershipTransferred

DelegateAdminContract.OwnershipTransferred(previousOwner, newOwner) `8be0079c`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | previousOwner | indexed |
| *address* | newOwner | indexed |


---
