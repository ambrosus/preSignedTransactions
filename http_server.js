const express = require('express')
const app = express()
const port = 3000

const ethHelper = require('./helpers.js')

app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});


app.get('/balance', function (req, res) {
	var token = req.query.token;
	var address = req.query.wallet;
	//turn off get request caching
	res.header('Cache-Control', 'private, no-cache, no-store, must-revalidate');
  	res.header('Expires', '-1');
  	res.header('Pragma', 'no-cache');
	
	console.log("Get balance request");
	console.log(token);
	console.log(address);
	

	res.send('0x0000000');
});

app.get('/nonce', function (req, res) {
	var token = req.query.token;
	var address = req.query.wallet;
	//turn off get request caching
	res.header('Cache-Control', 'private, no-cache, no-store, must-revalidate');
  	res.header('Expires', '-1');
  	res.header('Pragma', 'no-cache');
	
	console.log("Get nonce request");
	console.log(token);
	console.log(address);
	
	ethHelper.getAccountNonce(token, address, (_value) => { res.send_(value); });
});

app.post('/preSignedTransaction', function (req, res) {
	var _token = req.query.token;
	var _from = req.query.from;
	var _to = req.query.to;
	var _value = req.query.value;
	var _signature = req.query.signature;

	console.log("Post preSignedTransaction request");
	console.log(_token);
	console.log(_from);
	console.log(_to);
	console.log(_value);
	console.log(_signature);

	ethHelper.performPreSignedTransaction(_token, _from, _to, _value, _nonce, _signature, (_value) => { res.send_(value); });
});

app.post('/createNewToken', function (req, res) {
	var _owner = req.query.owner;
	var _symbol = req.query.symbol;
	var _name = req.query.name;
	var _decimals = req.query.decimals;
	var _initialSupply = req.query.initialSupply;
         var _nonce = req.query.nonce;

	console.log(_owner);
	console.log(_symbol);
	console.log(_name);
	console.log(_decimals);
	console.log(_initialSupply);
        
         ethHelper.deployTokenSmartcontract(_owner, _symbol, _name, _decimals, _initialSupply, (_value) => { res.send_(_value); });
});

app.listen(port, () => console.log(`Example app listening on port ${port}!`))
