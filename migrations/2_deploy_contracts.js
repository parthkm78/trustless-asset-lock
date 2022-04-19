var TrustlessTimeLockerFactory = artifacts.require("TrustlessTimeLockerFactory");

module.exports = function(deployer) {
  deployer.deploy(TrustlessTimeLockerFactory);
};
