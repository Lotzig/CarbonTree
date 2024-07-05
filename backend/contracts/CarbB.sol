// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../.deps/BokkyPooBahs/contracts/BokkyPooBahsDateTimeLibrary.sol";

/// @title CARB-B Token contract
/// @author JF Briche
/// @notice The token represents a tree that will be planted in a field
contract CarbB is ERC20, Ownable {
    
    using Strings for uint;

    constructor() ERC20("CARBONTREE B", "CARB-B") Ownable(msg.sender) {}

    /// @notice The token tree properties
    struct TokenTree {
        uint id;
        string species;
        uint purchaseDate;
        uint purchasePrice;
        uint plantingDate;
        string location;
        string locationOwnerName;
        string locationOwnerAddress;
    }

    //pour tests
    // uint public lastTokenTreeId;
    // uint public price;
    uint lastTokenTreeId;
    uint price;


    ///@dev The tree collection of each customer
    mapping(address => TokenTree[]) public customersTreeCollections;
    
    ///@notice Set the token/tree price 
    function setPrice(uint _price) external onlyOwner {
        require(_price > 0, "Tree price can not be nul");
        price = _price;
    }

    ///@notice Get the token/tree price
    function getPrice() external view returns (uint) {
        return price;
    }

    ///@notice Buy a token/tree and add it in the customer tree collection
    function buy (string memory _species, uint _plantingDate, string memory _location, 
                    string memory _locationOwnerName, string memory _locationOwnerAddress ) external payable {
        
        require(msg.sender != address(0), "Purchaser address can not be nul");
        require(price != 0, "Current token/tree price not set (admin)");
        require(msg.value == price, string.concat("Incorrect amount", ", sent : ", Strings.toString(msg.value), " current price is ", Strings.toString(price)));
        require(bytes(_species).length != 0, "_species can not be empty");
        require(_plantingDate != 0, "_plantingDate can not be nul");
        require(bytes(_location).length != 0, "_location can not be empty");
        require(bytes(_locationOwnerName).length != 0, "_locationOwnerName can not be empty");
        require(bytes(_locationOwnerAddress).length != 0, "_locationOwnerAddress can not be empty");

        _mint(msg.sender, 1);

        ++lastTokenTreeId;

        TokenTree memory tokenTree = TokenTree({id: lastTokenTreeId, 
                                                species: _species, 
                                                purchaseDate: block.timestamp, 
                                                purchasePrice: price, 
                                                plantingDate: _plantingDate, 
                                                location: _location, 
                                                locationOwnerName: _locationOwnerName, 
                                                locationOwnerAddress: _locationOwnerAddress});

        customersTreeCollections[msg.sender].push(tokenTree);
    }
}

