const main = async () => {
    const [deployer, address2, address3] = await hre.ethers.getSigners();
    const escrowContractFactory = await hre.ethers.getContractFactory("Escrow");
    const escrowContract = await escrowContractFactory.deploy();
    await escrowContract.deployed();
    console.log("Contract addy:", escrowContract.address);
  
    let contractBalance = await hre.ethers.provider.getBalance(
      escrowContract.address
    );
    console.log(
      "Contract balance:",
      hre.ethers.utils.formatEther(contractBalance)
    );
  

    await escrowContract.connect(deployer).writeNewContract(address2.address, address3.address, {
        value: hre.ethers.utils.parseEther("100"),
    });

    contractBalance = await hre.ethers.provider.getBalance(escrowContract.address);
    console.log(
      "Contract balance:",
      hre.ethers.utils.formatEther(contractBalance)
    );

    await escrowContract.connect(deployer).writeNewContract(address2.address, address3.address, {
        value: hre.ethers.utils.parseEther("90"),
    });
    
    contractBalance = await hre.ethers.provider.getBalance(escrowContract.address);
    console.log(
        "Contract balance:",
        hre.ethers.utils.formatEther(contractBalance)
      );

    await escrowContract.connect(address2).dismissEscrow(1);

    contractBalance = await hre.ethers.provider.getBalance(escrowContract.address);
    console.log(
        "Contract balance:",
        hre.ethers.utils.formatEther(contractBalance)
      );

    await escrowContract.connect(address3).approveArbiter(0);
    await escrowContract.connect(address2).approve(0);

    contractBalance = await hre.ethers.provider.getBalance(escrowContract.address);
    console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
    );

    let allContracts = await escrowContract.getAllContracts();
    console.log(allContracts);
  };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();