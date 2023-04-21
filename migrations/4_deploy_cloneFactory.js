const CloneFactory = artifacts.require("CloneFactory");

module.exports = function (deployer) {
  deployer.deploy(CloneFactory);
};
