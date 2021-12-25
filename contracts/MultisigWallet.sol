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
        uint256 indexed txIndex,
        uint256 value,
        bytes data
    );
    event ConfirmTxn(address indexed owner, uint256 indexed txIndex);
    event ExecuteTxn(address indexed owner, uint256 indexed txIndex);
    event RevokeTxn(address indexed owner, uint256 indexed txIndex);
    event Deposit(address indexed owner, uint256 value, uint256 balances);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public numOfConfirmationsRequired;
    struct Txn {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    mapping(uint256 => mapping(address => bool)) public isConfirmed;
    Txn[] public txns;

    constructor(address[] memory _owners, uint256 _numOfConirmationsRequired) {
        require(_owners.length > 0, "Owners required");
        require(
            _numOfConirmationsRequired > 0 &&
                _numOfConirmationsRequired <= _owners.length,
            "Invalid number of required confirmations"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(
                !isOwner[owner],
                "Not a unique owner, duplicate owner found"
            );
            isOwner[owner] = true;
            owners.push(owner);
        }
        numOfConfirmationsRequired = _numOfConirmationsRequired;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    //  To easily deposit from remix.
    function deposit() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Only owner can call this");
        _;
    }
    modifier txExists(uint256 _txIndex) {
        require(_txIndex < txns.length, "txn does not exist");
        _;
    }
    modifier notExecuted(uint256 _txIndex) {
        require(!txns[_txIndex].executed, "Txn already executed");
        _;
    }
    modifier notConfirmed(uint256 _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "Txn already confirmed");
        _;
    }

    function submitTxn(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public onlyOwner {
        uint256 txIndex = txns.length;
        txns.push(
            Txn({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0
            })
        );

        emit SubmitTxn(msg.sender, _to, txIndex, _value, _data);
    }

    function confirmTxn(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Txn storage transaction = txns[_txIndex];
        isConfirmed[_txIndex][msg.sender] = true;
        transaction.numConfirmations += 1;

        emit ConfirmTxn(msg.sender, _txIndex);
    }

    function executeTxn(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Txn storage transaction = txns[_txIndex];
        require(
            transaction.numConfirmations >= numOfConfirmationsRequired,
            "Cannot execute txn, need more confirmations"
        );
        transaction.executed = true;

        // Execute txn
        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "Txn failed");

        emit ExecuteTxn(msg.sender, _txIndex);
    }

    // revokes or cancells a txn : takes input as txn index
    function revokeTxn(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Txn storage transaction = txns[_txIndex];
        require(isConfirmed[_txIndex][msg.sender], "txn not confirmed yet.");
        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeTxn(msg.sender, _txIndex);
    }

    //  Helper functions
    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTxnCount() public view returns (uint256) {
        return txns.length;
    }

    function getTxn(uint256 _txIndex)
        public
        view
        returns (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 numConfirmations
        )
    {
        Txn storage transaction = txns[_txIndex];
        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}
