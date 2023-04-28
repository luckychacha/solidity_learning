var web3;
var chainId;
var accountAddress;
var ERC20FactoryABI = [
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "cloneFactory",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "erc20Template",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "customErc20Template",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "customMintableErc20Template",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "createFee",
        "type": "uint256"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "newFee",
        "type": "uint256"
      }
    ],
    "name": "ChangeCreateFee",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "newCustomMintableTemplate",
        "type": "address"
      }
    ],
    "name": "ChangeCustomMintableTemplate",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "newCustomTemplate",
        "type": "address"
      }
    ],
    "name": "ChangeCustomTemplate",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "newStdTemplate",
        "type": "address"
      }
    ],
    "name": "ChangeStdTemplate",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "erc20",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "creator",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "erc20Type",
        "type": "uint256"
      }
    ],
    "name": "NewERC20",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "previousOwner",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "OwnershipTransferPrepared",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "previousOwner",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "OwnershipTransferred",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "account",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "Withdraw",
    "type": "event"
  },
  {
    "stateMutability": "payable",
    "type": "fallback",
    "payable": true
  },
  {
    "inputs": [],
    "name": "_CLONE_FACTORY_",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [],
    "name": "_CREATE_FEE_",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [],
    "name": "_CUSTOM_ERC20_TEMPLATE_",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [],
    "name": "_CUSTOM_MINTABLE_ERC20_TEMPLATE_",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [],
    "name": "_ERC20_TEMPLATE_",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [],
    "name": "_NEW_OWNER_",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [],
    "name": "_OWNER_",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "_USER_CUSTOM_MINTABLE_REGISTRY_",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "_USER_CUSTOM_REGISTRY_",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "_USER_STD_REGISTRY_",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [],
    "name": "claimOwnership",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "initOwner",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "transferOwnership",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "stateMutability": "payable",
    "type": "receive",
    "payable": true
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "totalSupply",
        "type": "uint256"
      },
      {
        "internalType": "string",
        "name": "name",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "symbol",
        "type": "string"
      },
      {
        "internalType": "uint8",
        "name": "decimals",
        "type": "uint8"
      }
    ],
    "name": "createStdERC20",
    "outputs": [
      {
        "internalType": "address",
        "name": "newERC20",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function",
    "payable": true
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "totalSupply",
        "type": "uint256"
      },
      {
        "internalType": "string",
        "name": "name",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "symbol",
        "type": "string"
      },
      {
        "internalType": "uint8",
        "name": "decimals",
        "type": "uint8"
      },
      {
        "internalType": "uint256",
        "name": "tradeBurnRatio",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "tradeFeeRatio",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "teamAccount",
        "type": "address"
      }
    ],
    "name": "createCustomERC20",
    "outputs": [
      {
        "internalType": "address",
        "name": "newCustomERC20",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function",
    "payable": true
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "initSupply",
        "type": "uint256"
      },
      {
        "internalType": "string",
        "name": "name",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "symbol",
        "type": "string"
      },
      {
        "internalType": "uint8",
        "name": "decimals",
        "type": "uint8"
      },
      {
        "internalType": "uint256",
        "name": "tradeBurnRatio",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "tradeFeeRatio",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "teamAccount",
        "type": "address"
      }
    ],
    "name": "createCustomMintableERC20",
    "outputs": [
      {
        "internalType": "address",
        "name": "newCustomMintableERC20",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function",
    "payable": true
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "user",
        "type": "address"
      }
    ],
    "name": "getTokenByUser",
    "outputs": [
      {
        "internalType": "address[]",
        "name": "stds",
        "type": "address[]"
      },
      {
        "internalType": "address[]",
        "name": "customs",
        "type": "address[]"
      },
      {
        "internalType": "address[]",
        "name": "mintables",
        "type": "address[]"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "newFee",
        "type": "uint256"
      }
    ],
    "name": "changeCreateFee",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "withdraw",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "newStdTemplate",
        "type": "address"
      }
    ],
    "name": "updateStdTemplate",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "newCustomTemplate",
        "type": "address"
      }
    ],
    "name": "updateCustomTemplate",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "newCustomMintableTemplate",
        "type": "address"
      }
    ],
    "name": "updateCustomMintableTemplate",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];

async function connect() {
  if (window.ethereum) {
    try {
      await window.ethereum.enable();
    } catch (error) {
      console.error("User denied account access.");
    }
    web3 = new Web3(window.ethereum);
  } else if (window.web3) {
    web3 = new Web3(window.ethereum);
  } else {
    alert("Please install wallet.");
  }

  chainId = await web3.eth.getChainId();
  var blockNumber = await web3.eth.getBlockNumber();
  var block = await web3.eth.getBlock(blockNumber);
  var blockTimestamp = block.timestamp;

  var account = await web3.eth.getAccounts();
  var address = account[0];
  accountAddress = address;

  var eth_balance = await web3.eth.getBalance(address);

  document.getElementById("chain_id").innerText = chainId;
  document.getElementById("block_number").innerText = blockNumber;
  document.getElementById("block_timestamp").innerText = blockTimestamp;
  document.getElementById("account_address").innerText = address;
  document.getElementById("current_eth_balance").innerText = eth_balance;
}

async function read() {
  var contractAddress = document.getElementById("contract_address").value;
  var instance = new web3.eth.Contract(ERC20FactoryABI, contractAddress);

  var clone_factory_address = await instance.methods._CLONE_FACTORY_().call();
  var clone_factory_address_href = `https://sepolia.etherscan.io/address/${clone_factory_address}`;

  var erc20_template_address = await instance.methods._ERC20_TEMPLATE_().call();
  var erc20_template_address_href = `https://sepolia.etherscan.io/address/${erc20_template_address}`;

  var custom_erc20_template_address = await instance.methods._CUSTOM_ERC20_TEMPLATE_().call();
  var custom_erc20_template_address_href = `https://sepolia.etherscan.io/address/${custom_erc20_template_address}`;

  var custom_mintable_erc20_template_address = await instance.methods._CUSTOM_MINTABLE_ERC20_TEMPLATE_().call();
  var custom_mintable_erc20_template_address_href = `https://sepolia.etherscan.io/address/${custom_mintable_erc20_template_address}`;

  var create_fee = await instance.methods._CREATE_FEE_().call();
  // var tokenTotalSupply = await instance.methods.totalSupply().call();
  // var accountAddressBalance = await instance.methods
  //   .balanceOf(accountAddress)
  //   .call();
  // console.log("accountAddressBalance:" + accountAddressBalance);

  document.getElementById("create_fee").innerText = web3.utils.fromWei(create_fee, "ether");
  document.getElementById("clone_factory_address").innerHTML = `<a href="${clone_factory_address_href}" target="_blank">${clone_factory_address}</a>`;
  document.getElementById("erc20_template_address").innerHTML = `<a href="${erc20_template_address_href}" target="_blank">${erc20_template_address}</a>`;
  document.getElementById("custom_erc20_template_address").innerHTML = `<a href="${custom_erc20_template_address_href}" target="_blank">${custom_erc20_template_address}</a>`;
  document.getElementById("custom_mintable_erc20_template_address").innerHTML = `<a href="${custom_mintable_erc20_template_address_href}" target="_blank">${custom_mintable_erc20_template_address}</a>`;

  var user_std_registry =  await instance.methods._USER_STD_REGISTRY_(accountAddress, 0).call();
  var user_custom_registry =  await instance.methods._USER_CUSTOM_REGISTRY_(accountAddress, 0).call();
  var user_custom_mintable_registry =  await instance.methods._USER_CUSTOM_MINTABLE_REGISTRY_(accountAddress, 0).call();

  console.log(user_std_registry);
  console.log(user_custom_registry);
  console.log(user_custom_mintable_registry);
}

async function create_std_erc20() {
  var contractAddress = document.getElementById("contract_address").value;
  var instance = new web3.eth.Contract(ERC20FactoryABI, contractAddress);

  var totalSupply = document.getElementById("std_total_supply").value;
  var name = document.getElementById("std_name").value;
  var symbol = document.getElementById("std_symbol").value;
  var decimals = document.getElementById("std_decimals").value;
  var stdERC20Data = instance.methods.createStdERC20(totalSupply, name, symbol, decimals).encodeABI();
  await run(contractAddress, stdERC20Data);


//   createStdERC20
// createCustomERC20
// createCustomMintableERC20
}
async function create_custom_erc20() {
  var contractAddress = document.getElementById("contract_address").value;
  var instance = new web3.eth.Contract(ERC20FactoryABI, contractAddress);

  var totalSupply = document.getElementById("custom_total_supply").value;
  var name = document.getElementById("custom_name").value;
  var symbol = document.getElementById("custom_symbol").value;
  var decimals = document.getElementById("custom_decimals").value;
  var tradeBurnRatio = document.getElementById("custom_trade_burn_ratio").value;
  var tradeFeeRatio = document.getElementById("custom_trade_fee_ratio").value;
  var teamAccount = document.getElementById("custom_team_account").value;
  var customERC20Data = instance.methods.createCustomERC20(totalSupply, name, symbol, decimals, tradeBurnRatio, tradeFeeRatio, teamAccount).encodeABI();
  await run(contractAddress, customERC20Data);
}
async function create_custom_mintable_erc20() {
  var contractAddress = document.getElementById("contract_address").value;
  var instance = new web3.eth.Contract(ERC20FactoryABI, contractAddress);

  var totalSupply = document.getElementById("custom_total_supply").value;
  var name = document.getElementById("custom_name").value;
  var symbol = document.getElementById("custom_symbol").value;
  var decimals = document.getElementById("custom_decimals").value;
  var tradeBurnRatio = document.getElementById("custom_trade_burn_ratio").value;
  var tradeFeeRatio = document.getElementById("custom_trade_fee_ratio").value;
  var teamAccount = document.getElementById("custom_team_account").value;
  var customMintableERC20Data = instance.methods.createCustomERC20(totalSupply, name, symbol, decimals, tradeBurnRatio, tradeFeeRatio, teamAccount).encodeABI();
  await run(contractAddress, customMintableERC20Data);
}

async function run(contractAddress, data) {
  // 预执行
  try {
    var estimateGasRes = await web3.eth.estimateGas({
      to: contractAddress,
      data: data,
      from: accountAddress,
      // value: "0x0",
      value: web3.utils.toWei("0.002", "ether"), // 设置交易附带的以太币数量
    });

    var gasPrice = await web3.eth.getGasPrice();

    let nonce = await web3.eth.getTransactionCount(accountAddress);

    let rawTransaction = {
      from: accountAddress,
      to: contractAddress,
      nonce: web3.utils.toHex(nonce),
      gasPrice: gasPrice,
      gas: estimateGasRes * 2,
      value: web3.utils.toWei("0.002", "ether"), // 设置交易附带的以太币数量
      data: data,
      chainId: chainId,
    };

    web3.eth
      .sendTransaction(rawTransaction)
      .on("transactionHash", function (hash) {
        console.log("txHash", hash);
        // `<a href="${custom_mintable_erc20_template_address_href}" target="_blank">${custom_mintable_erc20_template_address}</a>
        document.getElementById("tx_hash").innerHTML = `<a href="https://sepolia.etherscan.io/tx/${hash}" target="_blank">${hash}</a>`;
      });
    document.getElementById("estimation").innerText = estimateGasRes;
    document.getElementById("gas_price").innerText =
      web3.utils.fromWei(gasPrice, "gwei");
  } catch (error) {
    // alert("execution reverted: Ownable: caller is not the owner");
    console.error(`Error Info: ${error.message}.`);
  }
}

