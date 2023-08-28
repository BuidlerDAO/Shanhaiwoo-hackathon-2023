import { HardhatUserConfig, NetworkUserConfig } from "hardhat/config";

// PLUGINS
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-truffle5";
import "@openzeppelin/hardhat-upgrades";
import "@typechain/hardhat";
import "hardhat-deploy";
import "hardhat-abi-exporter";
import "hardhat-contract-sizer";
import "solidity-coverage";
//import "hardhat-gas-reporter";

const KEY_TESTNET = '';
const KEY_MAINNET = '';

const bscTestnet: NetworkUserConfig = {
    url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
    chainId: 97,
    accounts: [KEY_TESTNET!],
    allowUnlimitedContractSize: true,
};

const bscMainnet: NetworkUserConfig = {
    url: "https://bsc-dataseed.binance.org/",
    chainId: 56,
    accounts: [KEY_MAINNET!],
    allowUnlimitedContractSize: true,
};

const config: HardhatUserConfig = {
    defaultNetwork: "hardhat",

    // hardhat-scripts
    namedAccounts: {
        deployer: {
            default: 0,
        },
    },

    networks: {
        hardhat: {
            allowUnlimitedContractSize: true,
        },
        localhost: {
            url: 'https://127.0.0.1:8545/',
            allowUnlimitedContractSize: true,
        },
        // testnet: bscTestnet,
        // mainnet: bscMainnet,
    },

    solidity: {
        compilers: [
            {
                version: "0.6.12",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                }
            },
            {
                version: "0.8.17",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    },
                },
            },
        ],
    },

    paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts",
    },

    typechain: {
        outDir: "typechain",
        target: "ethers-v5",
    },

    // gasReporter: {
    //     enabled: true,
    //     currency: 'CNY',
    // }

    etherscan: {
        apiKey: "",
        customChains: [],
    },
};

export default config;
