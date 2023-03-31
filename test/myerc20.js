const MyERC20 = artifacts.require("MyERC20");

contract("MyERC20", (accounts) => {
  it("mint token", async () => {
    const instance = await MyERC20.deployed();

    let feeRatio = 10;
    let burnRatio = 20;
    let feeAddress = accounts[2];
    await instance.setTradeRule(feeAddress, feeRatio, burnRatio);

    let account = accounts[0];
    let amount = 1000000;
    await instance.mint(account, amount);
    const account_one_balance = await instance.balanceOf.call(account);
    assert.equal(account_one_balance.toNumber(), 1000000);

    let burnAmount = 100000;
    await instance.burn(burnAmount);
    const account_one_balance_burn = await instance.balanceOf.call(account);
    assert.equal(account_one_balance_burn.toNumber(), amount - burnAmount);

    let receiver = accounts[3];
    await instance.transfer(receiver, 500000);
    const account_one_balance_transfer = await instance.balanceOf.call(account);
    assert.equal(account_one_balance_transfer.toNumber(), 400000);

    const realReceived = 500000 - (500000 * 10) / 1000 - (500000 * 20) / 1000;
    const receiver_balance = await instance.balanceOf.call(receiver);
    assert.equal(receiver_balance.toNumber(), realReceived);
  });
});
