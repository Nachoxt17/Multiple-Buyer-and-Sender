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

  //+-Sign the transaction:_
  const signPromise = web3.eth.accounts.signTransaction(
    tx,
    ROPSTEN_PRIVATE_KEY
  );
  signPromise
    .then((signedTx) => {
      web3.eth.sendSignedTransaction(
        signedTx.rawTransaction,
        function (err, hash) {
          if (!err) {
            console.log(
              "The hash of your transaction is: ",
              hash,
              "\n Check Alchemy's Mempool to view the status of your transaction!"
            );
          } else {
            console.log(
              "Something went wrong when submitting your transaction:",
              err
            );
          }
        }
      );
    })
    .catch((err) => {
      console.log("Promise failed:", err);
    });
}

async function isWhiteListMemberContract() {
  const nonce = await web3.eth.getTransactionCount(
    ROPSTEN_PUBLIC_ADDRESS,
    "latest"
  ); // get latest nonce
  const gasEstimate = await multipleBuyerAndSellerContract.methods
    .isWhiteListMember(ROPSTEN_PUBLIC_ADDRESS)
    .estimateGas(); // estimate gas

  //+-Create the transaction:_
  const tx = {
    from: ROPSTEN_PUBLIC_ADDRESS,
    to: contractAddress,
    nonce: nonce,
    gas: gasEstimate,
    data: multipleBuyerAndSellerContract.methods
      .isWhiteListMember(ROPSTEN_PUBLIC_ADDRESS)
      .encodeABI(),
  };

  //+-Sign the transaction:_
  const signPromise = web3.eth.accounts.signTransaction(
    tx,
    ROPSTEN_PRIVATE_KEY
  );
  signPromise
    .then((signedTx) => {
      web3.eth.sendSignedTransaction(
        signedTx.rawTransaction,
        function (err, hash) {
          if (!err) {
            console.log(
              "The hash of your transaction is: ",
              hash,
              "\n Check Alchemy's Mempool to view the status of your transaction!"
            );
          } else {
            console.log(
              "Something went wrong when submitting your transaction:",
              err
            );
          }
        }
      );
    })
    .catch((err) => {
      console.log("Promise failed:", err);
    });
}

async function ExecuteFunctionsHere() {
  //const SeeWhiteList = await SeeAddressesWhiteListInContract();
  //console.log("The Addresses in the White List Are: " + SeeWhiteList);
  const isWLMember = await isWhiteListMemberContract();
  console.log("Is this User a WhiteListMember?: " + isWLMember);
}
ExecuteFunctionsHere();
