const hre = require("hardhat");

async function main() {
  const tokenAddress = "0x..."; // Replace with your ERC20 token
  const quorum = hre.ethers.parseUnits("1000", 18); // 1000 tokens needed for quorum

  const Governor = await hre.ethers.getContractFactory("SimpleGovernor");
  const gov = await Governor.deploy(tokenAddress, quorum);

  await gov.waitForDeployment();
  console.log("DAO Governor deployed to:", await gov.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
