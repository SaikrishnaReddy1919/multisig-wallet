// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title MultisigWallet
 * @dev Implements multi signature wallet. 
 */

 contract MultisigWallet {
    //  event to be fired when txn is submitted
     event SubmitTxn(
         address indexed owner,
         address indexed to,
         uint indexed txIndex,
         uint value,
         bytes data
     );
     event ConfirmTxn(address indexed owner, uint indexed txIndex);
     event ExecuteTxn(address indexed owner, uint indexed txIndex);



     address[] public owners;
     mapping(address => bool) public isOwner;
     uint public numOfConfirmationsRequired;
     struct Txn {
         address to;
         uint value;
         bytes data;
         bool executed;
         mapping(address => bool) isConfirmed;
         uint numConfirmations;
     }
     Txn[] public txns;



     constructor(address[] memory _owners, uint _numOfConirmationsRequired) {
         require(_owners.length > 0, "Owners required");
         require(_numOfConirmationsRequired > 0 && _numOfConirmationsRequired <= _owners.length, "Invalid number of required confirmations");

         for(uint i = 0;i < _owners.length; i++){
             address owner = _owners[i];
             require(owner != address(0), "Invalid owner");
             require(!isOwner[owner], "Not a unique owner, duplicate owner found");
             isOwner[owner] = true;
             owners.push(owner);
         }
         numOfConfirmationsRequired = _numOfConirmationsRequired;
     }



     modifier onlyOwner() {
         require(isOwner[msg.sender], "Only owner can call this");
         _;
     }
     modifier txExists(uint _txIndex) {
         require(_txIndex < txns.length, "txn does not exist");
         _;
     }
     modifier notExecuted(uint _txIndex) {
         require(!txns[_txIndex].executed, "Txn already executed");
         _;
     }
     modifier notConfirmed(uint _txIndex) {
         require(!txns[_txIndex].isConfirmed[msg.sender], "Txn already confirmed");
         _;
     }



     function submitTxn(address _to, uint _value, bytes memory _data) public onlyOwner {
         uint txIndex = txns.length;
         txns.push(Txn({
             to : _to,
             value : _value,
             data : _data,
             executed : false,
             numConfirmations : 0
         }));

         emit SubmitTxn(msg.sender, _to, txIndex, _value, _data);
     }

     function confirmTxn(uint _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex) {
         Txn storage transaction = txns[_txIndex];
         transaction.isConfirmed[msg.sender] = true;
         transaction.numConfirmations += 1;

         emit ConfirmTxn(msg.sender, _txIndex);
     }

     function executeTxn(uint _txIndex) public onlyOwner 
     txExists(_txIndex)
     notExecuted(_txIndex) {
         Txn storage transaction = txns[_txIndex];
         require(transaction.numConfirmations >= numOfConfirmationsRequired, "Cannot execute txn, need more confirmations");
         transaction.executed = true;

        // Execute txn
         (bool success, ) = transaction.to.call.value(transaction.value)(transaction.data);
         require(success, "Txn failed");

         emit ExecuteTxn(msg.sender, _txIndex);
     }
 }