loadScript('build/combined.js');

var abi = JSON.parse(combined.contracts['LifDev.sol:LifDev'].abi);
var bin = '0x' + combined.contracts['LifDev.sol:LifDev'].bin;

var LifDev = eth.contract(abi);

var newLifDev = LifDev.new(100000000000, {
  from: '0xa6e96ac2c446f89699479fbb1bf0de93719e2105',
  data: bin,
  gas: 500000
});

miner.start()

setTimeout(function () {
  var address = eth.getTransactionReceipt(newLifDev.transactionHash).contractAddress
  console.log(address)
  miner.stop()
}, 2000);
