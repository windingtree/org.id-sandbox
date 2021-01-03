global.web3 = web3;
const path = require('path');
const fs = require('fs');
const { parseArgv } = require('../node_modules/@windingtree/smart-contracts-tools/src/utils/cli');
const Lif = artifacts.require('LifTest');

const main = async () => {
    const { from } = parseArgv(process.argv, 6);

    const lif = await Lif.new('Lif', 'LIF', 18, '100000000000000000000000000', {
        from
    });

    console.log('LIF token address:', lif.address);

    const configFile = {
        address: lif.address
    };
    const configFileName = 'lif.json';
    const configFilePath = path.resolve(
        process.cwd(),
        configFileName
    );
    console.log('LIF config file path:', configFilePath);

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
