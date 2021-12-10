const DBC = artifacts.require("DBC");

module.exports = async function(deployer) {
    //deploy Token
    await deployer.deploy(DBC)
    //assign token into variable to get it's address
    // const token = await DBC.deployed()
};
