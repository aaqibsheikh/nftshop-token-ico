const { ethers } = require("hardhat");

require("dotenv").config({ path: ".env" });

const { NFTSHOP_CONTRACT_ADDRESS } = require("../constants");

async function main() {
    const NFTShopContract = NFTSHOP_CONTRACT_ADDRESS;

    const NFTShopTokenContract = await ethers.getContractFactory("NFTShopToken");

    //deploy the contract
    const deployedNFTShopToken = await NFTShopTokenContract.deploy(NFTShopContract);
    await deployedNFTShopToken.deployed();

    console.log("NFTShop Token contract address is", deployedNFTShopToken.address);
}


main().then(() => process.exit(0)).catch((error) => { console.log(error); process.exit(1) });