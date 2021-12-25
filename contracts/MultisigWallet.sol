// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title MultisigWallet
 * @dev Implements multi signature wallet. 
 * @dev will explain the usage and description of every variable and function after completing full code
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
     function submitTxn() public {}
 }