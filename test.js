const ethUtil = require('ethereumjs-util');

const formattedAddress = address => Buffer.from(ethUtil.stripHexPrefix(address), 'hex');
const formattedInt = int => ethUtil.setLengthLeft(int, 32);
const formattedBytes32 = bytes => ethUtil.addHexPrefix(bytes.toString('hex'));
const hashedTightPacked = args => ethUtil.sha3(Buffer.concat(args));


const fixSignature = (signature) => {
  // in geth its always 27/28, in ganache its 0/1. Change to 27/28 to prevent
  // signature malleability
  // https://github.com/ethereum/go-ethereum/blob/master/internal/ethapi/api.go#L447
  const v = parseInt(signature.slice(130, 132), 16) + 27;
  const vHex = v.toString(16);
  return signature.slice(0, 130) + vHex;
};


components = [
        formattedAddress('0xee7DADC94485Ae9d41EA6ee9C0Fc08Ab1F244D17'),
        formattedAddress('0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db'),
        formattedInt(1000),
      ];

console.log(Buffer.concat(components).toString('hex'));


const hash = hashedTightPacked(components);
console.log(hash.toString('hex'))

const vrs = ethUtil.ecsign(hashedTightPacked(components), Buffer.from('f55f09842ac5b0668662e10a997af184b250a253c56acbd80249d00d92111b03', 'hex'));
console.log(vrs)


const sig = ethUtil.toRpcSig(vrs.v, vrs.r, vrs.s);
console.log(sig.toString('hex'));

const fixedSignature = fixSignature(sig);
console.log(fixedSignature.toString('hex'));
