pragma solidity ^0.8.0 < 0.9.0;

contract Auction {
  uint private highest_bid;
  uint private cool_time;
  uint private close_date;
  uint private init_fund;
  address private highest_bidder;
  address private ownerAddr;
  enum states { Open, Closed }
  states private curState;

  event receiveFund(address _from, uint _amount);

  constructor() payable {
    require(msg.value >= 1 ether, "init deposit less than 1 ether");
    highest_bid = 0;
    highest_bidder = msg.sender;
    cool_time = 1 days;
    close_date = block.timestamp + cool_time;
    init_fund = msg.value;
    ownerAddr = msg.sender;
  }

  receive() external payable {
    emit receiveFund(msg.sender, msg.value);
  }
 
  modifier initFund() {
    require(msg.value >= 1 ether, "transfer < 1 ether, not enough");
    _;
  }

  modifier emptyFund() {
    require(address(this).balance == 0, "Fund is not empty: withdraw first");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == ownerAddr, "owner only");
    _;
  }

  modifier onlyWinner() {
    require(msg.sender == ownerAddr, "winner only");
    _;
  }

  modifier whenOpen() {
    require(curState == states.Open, "Game is closed");
    _;
  }

  modifier whenClosed() {
    require(curState == states.Closed, "Game is still open");
    _;
  }

  function getBalance() external view returns (uint) {
    return address(this).balance;
  }

  function withdraw() external whenClosed
                               onlyOwner
                               onlyWinner {
    payable(msg.sender).transfer(address(this).balance);
  }

  function getLeader() external view returns (address) {
    return highest_bidder;
  }

  function closeGame() external whenOpen
                                onlyOwner {
    require(block.timestamp > close_date, "close game failed: game is still going");
    curState = states.Closed;
  }

  function openGame() external payable whenClosed
                                       onlyOwner
                                       emptyFund
                                       initFund {
    curState = states.Open;
    highest_bid = 0;
    init_fund = msg.value;
    assert(reset_close_date());
  }

  function reset_close_date() internal returns (bool) {
    close_date = block.timestamp + cool_time;
    return true;
  }

  function bid() external payable whenOpen {
    require(msg.value > highest_bid, "bid is not high enough");
    highest_bid = msg.value;
    highest_bidder = msg.sender;
    assert(reset_close_date());
  }

  function kill() external onlyOwner {
    selfdestruct(payable(msg.sender));
  }
}

