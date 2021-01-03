global.web3 = web3;
const path = require('path');
const fs = require('fs');
const { parseArgv } = require('@windingtree/smart-contracts-tools/src/utils/cli');
const Arbitrator = artifacts.require('EnhancedAppealableArbitrator');

const arbitrationCost = 1000;
const arbitratorExtraData = '0x85';
const appealTimeOut = 180;

const main = async () => {
    const { governor } = parseArgv(process.argv, 6);

    const arbitrator = await Arbitrator.new(
        arbitrationCost,
        governor,
        arbitratorExtraData,
        appealTimeOut,
        {
            from: governor
        }
    );

    console.log('Arbitrator address:', arbitrator.address);
    console.log('Arbitration Cost:', arbitrationCost);
    console.log('Extra Data:', arbitratorExtraData);
    console.log('Appeal TimeOut:', appealTimeOut);

    const configFile = {
        address: arbitrator.address,
        arbitrationCost,
        arbitratorExtraData,
        appealTimeOut
    };
    const configFileName = 'arbitrator.json';
    const configFilePath = path.resolve(
        process.cwd(),
        configFileName
    );

    fs.writeFileSync(
        configFilePath,
        JSON.stringify(configFile, null, 2),
        {
            encoding: 'utf8'
        }
    );
};

module.exports = callback => main()
    .then(() => callback())
    .catch(err => callback(err));
