# multisig-wallet

This repo will be about coding the multisig Wallet and will also develop frontend part for this.

### What is multisig wallet ?

- Multisig means Multiple signatures. That means a multisig wallet has not one owner but multiple owners.
- To spend from this wallet, owner need to get approval from other owners.

#### Example

- **2 out of 3 MULTISIG WALLET** - which requires atleast 2 owners approval out of 3 owners.
- Let's say there is a wallet with three owners(Alice, bob, carol). And Alice wants to withdraw 1BTC from this wallet. So, for Alice to withdraw 1BTC successfully atleat 2 owners should agree out of three owners.
- If one owner from bob or carol approves the txn then alice can withdraw 1BTC.
- If both Bob and Carol rejects the txn then the txn by Alice for withdrawing 1BTC will be revoked. Because the wallet here is **2 out of 3 multisig** wallet. So atleast 2 approvals are required including alice approval.

Everything about owners setting, number of approvals required, revoking transaction etc.. all will be done in a **Smart Contract**.


Find the explanation for the smart contract at [devto/SaikrishnaReddy](https://dev.to/saikrishnareddy1919/multisig-wallet-smart-contract-explanation-2eek)

##### Follow me on [![twitter][1.1]][1]

[1.1]: https://i.imgur.com/iYkheW1.png
[1]: https://twitter.com/blockchain_dev2