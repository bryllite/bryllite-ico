var HDWalletProvider = require('truffle-hdwallet-provider');
var infura_apikey = 'X79nsSctU4b1gjfdcHoO';
var mnemonic = 'order undo globe together habit object meat dinosaur awful slight shield inch';

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id,
      gas: 1000000
    },
    ropsten: {
    	provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/"+infura_apikey),
      network_id: 3,
      gas: 3000000
    },
    rinkeby: {
      host: "localhost", // Connect to geth on the specified
      port: 8545,
      from: "0xcd63ab567c2727b74ad418658a99221aa3e598bb", //qwer12341!// default address to use for any transaction Truffle makes during migrations
      network_id: 4,
      gas: 4612388 // Gas limit used for deploys
    },
    live: {
      host: "localhost",
      port: 8546,
      network_id: 1        // Ethereum public network
    }
  }
};
