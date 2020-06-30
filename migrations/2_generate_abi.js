let fs = require("fs");
const fsPromises = fs.promises;

async function deploy(deployer, networkName, accounts) {
    const deployed = require('../.openzeppelin/' + networkName + '.json');
    console.log('Writing results...');
    let artifactsObject = {};
    for (let key of Object.keys(deployed.proxies)) {
        const contractName = key.split('/')[1];
        propertyName = contractName.replace(/([a-zA-Z])(?=[A-Z])/g, '$1_').toLowerCase();
        artifactsObject[propertyName + "_address"] = deployed.proxies[key][0].address;
        artifactsObject[propertyName + "_abi"] = artifacts.require("./" + contractName).abi;
    }

    await fsPromises.writeFile(`data/${networkName}.json`, JSON.stringify(artifactsObject));
    console.log(`Done, check ${networkName}.json file in data folder.`);
}

module.exports = deploy;
