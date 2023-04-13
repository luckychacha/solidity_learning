var web3;
var chainId;
var accountAddress;
var myErc20Abi = [
    {
        "inputs": [],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "owner",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "spender",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "value",
                "type": "uint256"
            }
        ],
        "name": "Approval",
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
                "indexed": true,
                "internalType": "address",
                "name": "from",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "to",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "value",
                "type": "uint256"
            }
        ],
        "name": "Transfer",
        "type": "event"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "owner",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "spender",
                "type": "address"
            }
        ],
        "name": "allowance",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "spender",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "name": "approve",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "account",
                "type": "address"
            }
        ],
        "name": "balanceOf",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_amount",
                "type": "uint256"
            }
        ],
        "name": "burn",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "burnRatio",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "decimals",
        "outputs": [
            {
                "internalType": "uint8",
                "name": "",
                "type": "uint8"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "spender",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "subtractedValue",
                "type": "uint256"
            }
        ],
        "name": "decreaseAllowance",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "feeAddress",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "feeRatio",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "spender",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "addedValue",
                "type": "uint256"
            }
        ],
        "name": "increaseAllowance",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_account",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_amount",
                "type": "uint256"
            }
        ],
        "name": "mint",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "name",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "owner",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "renounceOwnership",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "addr",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_feeRatio",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "_burnRatio",
                "type": "uint256"
            }
        ],
        "name": "setTradeRule",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "symbol",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "totalSupply",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_to",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_amount",
                "type": "uint256"
            }
        ],
        "name": "transfer",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "from",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "to",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "name": "transferFrom",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
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

    var balance = await web3.eth.getBalance(address);
    
    document.getElementById("chain_id").innerText = chainId;
    document.getElementById("block_number").innerText = blockNumber;
    document.getElementById("block_timestamp").innerText = blockTimestamp;
    document.getElementById("account_address").innerText = address;
    document.getElementById("current_balance").innerText = balance;

}

async function read() {
    var contractAddress = document.getElementById("contract_address").value;
    var instance = new web3.eth.Contract(myErc20Abi, contractAddress);

    var tokenSymbol = await instance.methods.symbol().call();
    var tokenTotalSupply = await instance.methods.totalSupply().call();
    var accountAddressBalance = await instance.methods.balanceOf(accountAddress).call();
    console.log("accountAddressBalance:" + accountAddressBalance);


    document.getElementById("token_symbol").innerText = tokenSymbol;
    document.getElementById("total_supply").innerText = tokenTotalSupply;
    document.getElementById("account_balance").innerText = accountAddressBalance;
}

async function transfer() {
    var contractAddress = document.getElementById("contract_address").value;
    var instance = new web3.eth.Contract(myErc20Abi, contractAddress);

    var toAddress = document.getElementById("to_address").value;
    var amount = document.getElementById("transfer_amount").value;

    var transferData = instance.methods.transfer(toAddress, amount).encodeABI();

    var accountAddressBalance = await instance.methods.balanceOf(accountAddress).call();
    console.log("accountAddressBalance:" + accountAddressBalance);
    // 预执行
    var estimateGasRes = await web3.eth.estimateGas({
        to: contractAddress,
        data: transferData,
        from: accountAddress,
        value: '0x0'
    });

    var gasPrice = await web3.eth.getGasPrice();

    let nonce = await web3.eth.getTransactionCount(accountAddress);

    let rawTransaction = {
        from: accountAddress,
        to: contractAddress,
        nonce: web3.utils.toHex(nonce),
        gasPrice: gasPrice,
        gas: estimateGasRes * 2,
        value: '0x0',
        data: transferData,
        chainId: chainId
    }

    // estimation
// gas_price
// tx_hash
    web3.eth.sendTransaction(rawTransaction).on("transactionHash", function(hash) {
        console.log("txHash", hash);
        document.getElementById("tx_hash").innerText = hash;
    });
    document.getElementById("estimation").innerText = estimateGasRes;
    document.getElementById("gas_price").innerText = web3.utils.fromWei(gasPrice, "gwei");


}

async function mint() {
    var contractAddress = document.getElementById("contract_address").value;
    var instance = new web3.eth.Contract(myErc20Abi, contractAddress);
    var owner = await instance.methods.owner().call();
    if (accountAddress != owner) {
        alert("caller is not the owner.");
        return;
    }

    var mintAmount = document.getElementById("mint_amount").value;
    var mintData = instance.methods.mint(accountAddress, mintAmount).encodeABI();
    await run(contractAddress, mintData);
}
async function burn() {
    var contractAddress = document.getElementById("contract_address").value;
    var instance = new web3.eth.Contract(myErc20Abi, contractAddress);
    var owner = await instance.methods.owner().call();
    if (accountAddress != owner) {
        alert("caller is not the owner.");
        return;
    }

    var burnAmount = document.getElementById("burn_amount").value;
    var burnData = instance.methods.burn(burnAmount).encodeABI();
    await run(contractAddress, burnData);
}

async function run(contractAddress, data) {
    // 预执行
    try {
        var estimateGasRes = await web3.eth.estimateGas({
            to: contractAddress,
            data: data,
            from: accountAddress,
            value: '0x0'
        });

        var gasPrice = await web3.eth.getGasPrice();

        let nonce = await web3.eth.getTransactionCount(accountAddress);

        let rawTransaction = {
            from: accountAddress,
            to: contractAddress,
            nonce: web3.utils.toHex(nonce),
            gasPrice: gasPrice,
            gas: estimateGasRes * 2,
            value: '0x0',
            data: data,
            chainId: chainId
        }

        web3.eth.sendTransaction(rawTransaction).on("transactionHash", function(hash) {
            console.log("txHash", hash);
            document.getElementById("mint_burn_tx_hash").innerText = hash;
        });
        document.getElementById("mint_burn_estimation").innerText = estimateGasRes;
        document.getElementById("mint_burn_gas_price").innerText = web3.utils.fromWei(gasPrice, "gwei");
    } catch (error) {
        // alert("execution reverted: Ownable: caller is not the owner");
        console.error(`Error Info: ${error.message}.`);
    }
}

async function query_by_address() {
    var contractAddress = document.getElementById("contract_address").value;
    var instance = new web3.eth.Contract(myErc20Abi, contractAddress);

    var queryAddress = document.getElementById("query_address").value;
    var queryAddressMETBalance = await instance.methods.balanceOf(queryAddress).call();
    document.getElementById("query_address_token_balance").innerText = queryAddressMETBalance;

    var ethBalance = await web3.eth.getBalance(queryAddress);
    console.log(`ethBalance: ${ethBalance} queryAddress: ${queryAddress}`)
    document.getElementById("query_address_eth_balance").innerText = ethBalance;

}