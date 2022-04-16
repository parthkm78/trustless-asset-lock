var TimeLockedWalletFactory = artifacts.require("TimeLockedWalletFactory");
var ERC20Token = artifacts.require("ERC20Token");

module.exports = function(deployer) {
  deployer.deploy(TimeLockedWalletFactory);
  deployer.deploy(ERC20Token);
};
