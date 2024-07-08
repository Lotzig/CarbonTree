require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.22",
};

require('hardhat-docgen')
docgen: {
     path: './docs';
     clear: true;
     runOnCompile: true;
};

