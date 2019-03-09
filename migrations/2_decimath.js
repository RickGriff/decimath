var DeciMath = artifacts.require("./DeciMath.sol");
var DeciMathCaller = artifacts.require("./DeciMathCaller.sol");

module.exports = function(deployer) {
  deployer.deploy(DeciMath);
  deployer.link(DeciMath, DeciMathCaller);
  deployer.deploy(DeciMathCaller);
};
