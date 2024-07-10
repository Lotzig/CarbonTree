const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("CarbBModule", (m) => {

  const carbB = m.contract("CarbB");

  return { carbB };
});

