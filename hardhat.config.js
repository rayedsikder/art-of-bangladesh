require("@nomiclabs/hardhat-waffle");

const path = require("path");
require("dotenv").config({
  path: path.resolve("process.env"),
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

extendEnvironment((hre) => {
  const Web3 = require("web3");
  hre.Web3 = Web3;

  // hre.network.provider is an EIP1193-compatible provider.
  hre.web3 = new Web3(hre.network.provider);
});

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// const accounts = {
//   mnemonic: process.env.MNEMONIC,
// };

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "fantomtest",
  networks: {
    localhost: {
      url: "http://127.0.0.1:7545",
    },
    alfajores: {
      url: "https://alfajores-forno.celo-testnet.org",
      accounts: [process.env.MNEMONIC],
      chainId: 44787,
    },
    fantomtest: {
      url: "https://rpc.testnet.fantom.network",
      accounts: [process.env.MNEMONIC],
      chainId: 4002
    }
  },
  solidity: {
    version: "0.8.4",
  },
  namedAccounts: {
    deployer: 0,
  },
};