require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.26",
};

require('hardhat-docgen')
docgen: {
     path: './docs';
     clear: true;
     runOnCompile: true;
};

