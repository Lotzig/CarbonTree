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
    uint public nextTokenTreeKey;
    uint public nextTokenTreeId;
    uint public price;
    uint public availableTokenTreeCount;
    // uint nextTokenTreeKey;
    // uint nextTokenTreeId;
    // uint price;
    // uint availableTokenTreeCount;

    ///@notice The whole token/tree collection
    mapping(uint tokenTreeId => TokenTree) public availableTokenTrees;

    ///@notice The token/tree collection of each customer
    mapping(address customer => mapping(uint customerTokenTreeKey => TokenTree customerTokenTreeCollection)) public customersTokenTreeCollections;
    
    ///@notice Set the token/tree price 
    function setPrice(uint _price) external onlyOwner {
        require(_price > 0, "Tree price can not be nul");
        price = _price;
    }

    ///@notice Get the token/tree price
    function getPrice() external view returns (uint) {
        return price;
    }

    ///@notice Add a token/tree in the available tokens/trees mapping
    function addTokenTree (string memory _species, uint _plantingDate, string memory _location, 
                    string memory _locationOwnerName, string memory _locationOwnerAddress ) external onlyOwner {
        
        require(bytes(_species).length != 0, "_species can not be empty");
        require(_plantingDate != 0, "_plantingDate can not be nul");
        require(bytes(_location).length != 0, "_location can not be empty");
        require(bytes(_locationOwnerName).length != 0, "_locationOwnerName can not be empty");
        require(bytes(_locationOwnerAddress).length != 0, "_locationOwnerAddress can not be empty");

        nextTokenTreeId++;

        TokenTree memory tokenTree = TokenTree({id: nextTokenTreeId, 
                                                species: _species, 
                                                purchaseDate: block.timestamp, 
                                                purchasePrice: price, 
                                                plantingDate: _plantingDate, 
                                                location: _location, 
                                                locationOwnerName: _locationOwnerName, 
                                                locationOwnerAddress: _locationOwnerAddress});

        nextTokenTreeKey = getLastAvailableTokenTreeKey() + 1;
        availableTokenTrees[nextTokenTreeKey] = tokenTree;
        ++availableTokenTreeCount;
    }

    function getLastAvailableTokenTreeKey() public view returns (uint) {

        uint i = 1;
        while (availableTokenTrees[i].id > 0) {
            ++i;
        }

        return --i;
    }

    ///@notice Remove a token/tree from collection
    function removeTokenTree(uint _tokenTreeId) external onlyOwner {
        
        require(availableTokenTrees[_tokenTreeId].id > 0, string.concat("Token tree not found. Token tree Id ", Strings.toString(_tokenTreeId), " does not exists"));
        delete availableTokenTrees[_tokenTreeId];

        // Recalibrate token keys (avoid "blank" tokens in the mapping)
        for(uint i = _tokenTreeId; i < availableTokenTreeCount; i++) {

            availableTokenTrees[i] = availableTokenTrees[i+1];

        }
        
        delete availableTokenTrees[availableTokenTreeCount];

        // Decrement token count
        --availableTokenTreeCount;
    }

    ///@notice Get tokens/trees available for selling
    function getAvailableTokenTrees() external view returns(TokenTree[] memory) {

        TokenTree[] memory tmpAvailableTokenTrees = new TokenTree[](availableTokenTreeCount + 1);

        for(uint i = 1; i <= availableTokenTreeCount; i++) {
            
            tmpAvailableTokenTrees[i] = availableTokenTrees[i];

        }

        return tmpAvailableTokenTrees;
    }

    ///@notice Buy a token/tree and add it in the customer tree collection
    function buy (uint _tokenTreeId ) external payable {
        
        require(msg.sender != address(0), "Purchaser address can not be nul");
        require(availableTokenTrees[_tokenTreeId].id > 0, string.concat("Token tree not found. Token tree Id ", Strings.toString(_tokenTreeId), " does not exists"));
        require(price != 0, "Current token/tree price not set (admin)");
        require(msg.value == price, string.concat("Incorrect amount", ", sent : ", Strings.toString(msg.value), ", current price is ", Strings.toString(price)));

        _mint(msg.sender, 1);

        uint nextCustomerTokenTreeKey = getLastCustomerTokenTreeKey(msg.sender) + 1;
        customersTokenTreeCollections[msg.sender][nextCustomerTokenTreeKey] = availableTokenTrees[_tokenTreeId];
        delete availableTokenTrees[_tokenTreeId];
    }

    ///@notice Get the last key in a customer token/tree mapping = the key of the last token/tree they own (NOT the token/tree id, the mapping key)
    function getLastCustomerTokenTreeKey(address _customer) public view returns (uint) {

        uint i = 1;
        while (customersTokenTreeCollections[_customer][i].id > 0) {
            ++i;
        }

        return --i;
    }
}

