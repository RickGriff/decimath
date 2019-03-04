var DeciMath = artifacts.require("./DeciMath.sol");

module.exports = function(deployer) {
  deployer.deploy(DeciMath);
};
