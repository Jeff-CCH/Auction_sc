const Auction = artifacts.require("Auction");

module.exports = function (deployer) {
  deployer.deploy(Auction, { value: 10**18 });
};
