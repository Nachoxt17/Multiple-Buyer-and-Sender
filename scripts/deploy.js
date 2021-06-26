async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const MultipleBuyerAndSender = await ethers.getContractFactory(
    "MultipleBuyerAndSender"
  );
  const multipleBuyerAndSender = await MultipleBuyerAndSender.deploy(
    "0xF3CB703D6b7f8af4878c3428C0043b8Bdffc4a33",
    "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f",
    "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
  );
  //+-(UniSwap Factory and Router S.C. Address).
  /**+-Ethereum MainNet & Ropsten TestNet D.EX.s Factory and Router Addresses:_
  +-UniSwap Factory Address = '0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f'(Is the Same in Both MainNet and TestNet).
  +-UniSwap Router Address = ' 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D'(Is the Same in Both MainNet and TestNet).*/

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
