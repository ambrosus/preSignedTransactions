const Web3 = require('web3');
const web3 = new Web3(Web3.providers.HttpProvider("http://localhost:8545"));
const fs = require('fs');

web3.eth.defaultAccount = '0x4dac8e1c2FdA85A206b63334F3A508d25159320E';

const contractBin = Buffer.from(fs.readFileSync("./out/multitoken.bin"));
const contractAbi = JSON.parse(fs.readFileSync("./out/multitoken.abi"));

module.exports = {
    deployTokenSmartcontract: function (_tokenOwner, _symbol, _name, _initialSupply, _callback) {

        let Token = new web3.eth.Contract(contractAbi, null, { data: '0x' + contractBin, });

        Token.deploy({
                        arguments: [_tokenOwner, _symbol, _name, _initialSupply],
                     })
        .send({
                from: web3.eth.defaultAccount,
                gas: 5000000,
              })
        .then((instance) => {
            _callback(instance.options.address);
            });
    },
    performPreSignedTransaction: function (_token, _tokenId, _from, _to, _value, _nonce, _signature, _callback) {
        let Token = new web3.eth.Contract(contractAbi, _token);
        Token.methods.transferPreSigned(_signature, _tokenId, _from, _to, _value, _nonce)
            .send({
                    from: web3.eth.defaultAccount,
                    gas: 5000000,
                  })
            .then((result) => {
                _callback("");
            });
    },
    addTokenToContract: function(_contract, _tokenOwner, _symbol, _name, _price, _initialSupply, _callback) {
        let Token = new web3.eth.Contract(contractAbi, _contract);
        Token.methods.createNewToken(_name, _symbol, _price, _tokenOwner, _initialSupply)
            .send({
                    from: web3.eth.defaultAccount,
                    gas: 5000000,
                  })
            .then((result) => {
                _callback("");
            });
    },
    getAccountNonce: function (_token, _from, _callback) {
        let Token = new web3.eth.Contract(contractAbi, _token);
        Token.methods.getAccountNonce(_from).call({from: web3.eth.defaultAccount})
        .then((result) => {
            _callback(result.toString());
        });
    },
    getAccountBalance: function (_contract, _tokenId, _owner, _callback) {
        let Token = new web3.eth.Contract(contractAbi, _contract);

        Token.methods.getTokensAmount().call({from: web3.eth.defaultAccount})
        .then (function (tokensAmount) {
            var promises = [];

            for (let i = 0; i < tokensAmount; ++i) {
                promises.push(Token.methods.getTokenName(i).call({from: web3.eth.defaultAccount})
                    .then(function (name) {
                        var result = {};
                        result.id = i;
                        result.name = name;
                        return Promise.all([Token.methods.getTokenSymbol(result.id).call({from: web3.eth.defaultAccount}), result]);
                    })
                    .then(function ([symbol, result]) {
                        result.symbol = symbol;
                        return Promise.all([Token.methods.getTokenPrice(result.id).call({from: web3.eth.defaultAccount}), result]);
                    })
                    .then(function ([price, result]) {
                        result.price = price;
                        return Promise.all([Token.methods.getTokenBalance(result.id, _owner).call({from: web3.eth.defaultAccount}), result]);
                    })
                    .then(function ([tokenBalance, result]) {
                        result.balance = tokenBalance;
                        return result;
                    })
                );
            }

            Promise.all(promises)
            .then( function (objects) {
                _callback(JSON.stringify(objects));
            });
        });
    },
    getTokensAmount: function (_callback) {
        let Token = new web3.eth.Contract(contractAbi, _token);
        Token.methods.getTokensAmount().call({from: web3.eth.defaultAccount})
        .then((result) => {
            _callback(result.toString());
        });
     },
     preSignedExchangeTokens: function(_contract, _owner, _tokenToSpendId, _tokenToBuyId, _amount, _cover, _nonce, _callback) {
        console.log('exchange called');
        let Token = new web3.eth.Contract(contractAbi, _contract);
        Token.methods.exchangeTokens(_owner, _amount, _tokenToSpendId, _tokenToBuyId, _cover == 'true')
            .send({
                    from: web3.eth.defaultAccount,
                    gas: 5000000,
                  })
            .then((result) => {
                _callback(0);
            });
     }

};
