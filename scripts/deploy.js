async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const MultipleBuyerAndSender = await ethers.getContractFactory(
    "MultipleBuyerAndSender"
  );
  const multipleBuyerAndSender = await MultipleBuyerAndSender
  .deploy( '0x----------------------------------------','0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f');
  //+-(UniSwap Factories S.C. Address).
  /**+-Ethereum MainNet & Ropsten TestNet D.EX.s Factory Addresses:_
  +-UniSwap Factory Address = '0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f'(Is the Same in Both MainNet and TestNet).*/

  console.log(
    "MultipleBuyerAndSender Contract Address:",
    multipleBuyerAndSender.address
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
