require("dotenv").config();
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
const ROPSTEN_PUBLIC_ADDRESS = process.env.ROPSTEN_PUBLIC_ADDRESS;
const ROPSTEN_PRIVATE_KEY = process.env.ROPSTEN_PRIVATE_KEY;

const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
const web3 = createAlchemyWeb3(
  `https://eth-ropsten.alchemyapi.io/v2/${ALCHEMY_API_KEY}`
);
const contract = require("../src/artifacts/contracts/MultipleBuyerAndSender.sol/MultipleBuyerAndSender.json");

//+-If you want to see the ABI you can print it to your console:_
//console.log(JSON.stringify(contract.abi));

const contractAddress = "0x11C5206Aa844c9583c94634A97B0eAbB3935f666";
const multipleBuyerAndSellerContract = new web3.eth.Contract(
  contract.abi,
  contractAddress
);

async function SeeAddressesWhiteListInContract() {
  const nonce = await web3.eth.getTransactionCount(
    ROPSTEN_PUBLIC_ADDRESS,
    "latest"
  ); // get latest nonce
  const gasEstimate = await multipleBuyerAndSellerContract.methods
    .SeeAddressesWhiteList()
    .estimateGas(); // estimate gas

  //+-Create the transaction:_
  const tx = {
    from: ROPSTEN_PUBLIC_ADDRESS,
    to: contractAddress,
    nonce: nonce,
    gas: gasEstimate,
    data: multipleBuyerAndSellerContract.methods
      .SeeAddressesWhiteList()
      .encodeABI(),
  };
}

/**
async function SeeAddressesWhiteListInContract() {
  const SeeAddressesWhiteList = await multipleBuyerAndSellerContract.methods
    .SeeAddressesWhiteList()
    .call();
  console.log("The Addresses in the White List Are: " + SeeAddressesWhiteList);
}
SeeAddressesWhiteListInContract();
*/
