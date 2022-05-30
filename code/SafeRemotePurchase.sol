// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract SafeRemotePurchase {
    // five minutes in seconds (solc does not reserve a storage slot)
    uint256 constant FIVE_MIN_IN_SEC = 5 minutes;

    uint256 public value;
    address payable public seller;
    address payable public buyer;
    // timestamp in seconds
    uint256 purchaseConfirmedTime;

    enum State {
        Created,
        Locked,
        Inactive
    }
    State public state;

    modifier condition(bool condition_) {
        require(condition_);
        _;
    }

    /// Only the buyer can call this function.
    error OnlyBuyer();
    /// Only the seller can call this function.
    error OnlySeller();
    /// The function cannot be called at the current state.
    error InvalidState();
    /// The provided value has to be even.
    error ValueNotEven();

    modifier onlyBuyer() {
        if (msg.sender != buyer) revert OnlyBuyer();
        _;
    }

    modifier onlySeller() {
        if (msg.sender != seller) revert OnlySeller();
        _;
    }

    modifier inState(State state_) {
        if (state != state_) revert InvalidState();
        _;
    }

    event Aborted();
    event PurchaseConfirmed();
    event PurchaseCompleted();

    function checkPurchaseConfirmedTime() private view returns (bool) {
        return (block.timestamp - FIVE_MIN_IN_SEC) >= purchaseConfirmedTime;
    }

    constructor() payable {
        seller = payable(msg.sender);
        value = msg.value / 2;
        if ((2 * value) != msg.value) revert ValueNotEven();
    }

    function abort() external onlySeller inState(State.Created) {
        emit Aborted();
        state = State.Inactive;

        seller.transfer(address(this).balance);
    }

    function confirmPurchase()
        external
        payable
        inState(State.Created)
        condition(msg.value == (2 * value))
    {
        emit PurchaseConfirmed();
        buyer = payable(msg.sender);
        state = State.Locked;
        purchaseConfirmedTime = block.timestamp;
    }

    // function that merges confirmReceived() and refundSeller()
    function completePurchase()
        external
        inState(State.Locked)
        condition(msg.sender == buyer || checkPurchaseConfirmedTime())
    {
        emit PurchaseCompleted();

        // change the state before calling transfer() 
        state = State.Inactive;

        buyer.transfer(value);
        seller.transfer(3 * value);
    }
}