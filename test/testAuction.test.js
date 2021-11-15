const Auction = artifacts.require("Auction");

contract("Auction", (accounts) =>{
  let auction;
  let [alice, bob] = accounts;
  beforeEach(async() => {
    auction = await Auction.deployed();
  });

  it("should have init fund", async () => {
    const balance = await auction.getBalance();
    assert.equal(balance, 10**18);
  });

  context("place a bid scenario", async () => {
    it("should accept a higher bid", async () => {
      await auction.bid({from: bob, value: 2*(10**18)});
      const leader = await auction.getLeader(); 
      console.log("leader: ", leader);
      assert.equal(leader, bob);
    });

//    it("should not accept a lowe bid", async () => {
//    });
  });
/*
  it("should be able to close the bid", async () => {
  });

  xcontext("withdraw balance scenario", async () => {
    it("should be able to withdraw by owner", async () => {
    });
    
    it("shoud be able to withdraw by winner", async () => {
    });
  })
*/

  afterEach(async () => {
    await auction.kill({ from: alice });
  });
});
