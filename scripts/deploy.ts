import { ethers } from "hardhat";

async function main() {
  // const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  // const unlockTime = currentTimestampInSeconds + 60;

  // const lockedAmount = ethers.parseEther("0.001");

  const contract = await ethers.deployContract("MxenGame", ["0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e", 432000]);

  await contract.waitForDeployment();

  // console.log(
  //   `Lock with ${ethers.formatEther(lockedAmount)}ETH and unlock timestamp ${unlockTime} deployed to ${lock.target}`
  // );
  console.log(`Deployed the game contract: ${contract.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});