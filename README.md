## +-MULTIPLE-BUYER-AND-SENDER:\_

+-For Testing the Successful S.C. DEO Deployed in the Ropsten Ethereum TestNet:\_
Smart Contract deployed with the account: 0xF3CB703D6b7f8af4878c3428C0043b8Bdffc4a33
https://ropsten.etherscan.io/address/0x11C5206Aa844c9583c94634A97B0eAbB3935f666

+-You can get Ropsten Test Ether Here:\_
https://faucet.dimensions.network

+-How to Interact with the Deployed Smart Contract:\_
https://docs.alchemy.com/alchemy/tutorials/hello-world-smart-contract/interacting-with-a-smart-contract#step-6-update-the-message

## +-Quick Project start:\_

+-(1)-The first things you need to do are cloning this repository and installing its
dependencies:

```sh
npm install
```

+-(2)-Secondly, Copy and Paste the File ".env.example" inside the same Root Folder(You will Duplicate It) and then rename it removing the part of ".example" so that it looks like ".env" and then fill all the Data Needed Inside the File. In the part of "ALCHEMY_API_KEY"
just write the KEY, not the whole URL.

+-(3)-Go to the File "deploy.js" inside the Folder "scripts" and replace the sample Address "0x----------------------------------------" with your Ropsten Ethereum TestNet Wallet Address. It must be the same Address which Private Key you used in ROPSTEN_PRIVATE_KEY="\*\*\*" in the ".env" File.

+-(4)-Now open a Terminal and let's run Ropsten Ethereum Test Network(https://hardhat.org/tutorial/deploying-to-a-live-network.html)(https://docs.openzeppelin.com/learn/deploying-and-interacting?pref=hardhat):\_

```sh
npx hardhat run scripts/deploy.js --network ropsten
```

+-(5)-To Interact with the Deployed S.C. you need to run contract-interact.js:\_

```sh
node scripts/contract-interact.js
```
