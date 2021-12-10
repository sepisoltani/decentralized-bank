const DBC = artifacts.require("DBC");
const Bank = artifacts.require("Bank");

module.exports = async function (deployer) {
    //deploy Token
    await deployer.deploy(DBC)
    // assign token into variable to get it's address
    const DBCToken = await DBC.deployed()
    //deploy bank
    await deployer.deploy(Bank, DBCToken.address)
    // assign bank into variable to get it's address
    const BankContract = await Bank.deployed()
    //change DBC token owner/minter to bank
    await DBCToken.passMinterRole(BankContract.address)
};
