module.exports = {
    networks: {
        development: {
            host: '0.0.0.0',
            port: 8545,
            network_id: '*', // eslint-disable-line camelcase
            gas: 8000000,
            gasPrice: 20000000000
        }
    },

    compilers: {
        solc: {
            version: '0.5.17',
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                }
            }
        }
    }
};
