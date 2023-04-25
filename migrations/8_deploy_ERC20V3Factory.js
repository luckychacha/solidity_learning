const ERC20V3Factory = artifacts.require("ERC20V3Factory");

module.exports = function (deployer) {
  let CloneFactoryAddress = process.env.CloneFactoryAddress;

  let ERC20Address = process.env.ERC20Address;
  let CustomERC20Address = process.env.CustomERC20Address;
  let CustomMintableERC20Address = process.env.CustomMintableERC20Address;
  console.log(`CloneFactoryAddress: ${CloneFactoryAddress}`);
  console.log(`ERC20Address: ${ERC20Address}`);
  console.log(`CustomERC20Address: ${CustomERC20Address}`);
  console.log(`CustomMintableERC20Address: ${CustomMintableERC20Address}`);

  deployer.deploy(
      ERC20V3Factory,
      CloneFactoryAddress,
      ERC20Address,
      CustomERC20Address,
      CustomMintableERC20Address,
      "2000000000000000" //0.002
  );
};
