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
        uint price;
        uint plantingDate;
        string location;
        string locationOwnerName;
        string locationOwnerAddress;
    }

    //pour tests
    uint public nextTokenTreeKey;   // Supprimer après les tests : toujours défini par getLastAvailableTokenTreeKey
    uint public nextTokenTreeId;    // A garder en private
    uint public availableTokenTreeCount;    // A garder en private ou public si info intéressante pour utilisateurs ou admin
    // uint nextTokenTreeId;
    // uint availableTokenTreeCount;

    ///@notice The whole token/tree collection
    mapping(uint tokenTreeId => TokenTree) public availableTokenTrees;

    ///@notice The token/tree collection of each customer
    mapping(address customer => mapping(uint customerTokenTreeKey => TokenTree customerTokenTreeCollection)) public customersTokenTreeCollections;

    ///@notice Add a token/tree in the available tokens/trees mapping
    function addTokenTree (string memory _species, uint _price, uint _plantingDate, string memory _location, 
                    string memory _locationOwnerName, string memory _locationOwnerAddress) external onlyOwner {
        
        require(bytes(_species).length != 0, "_species can not be empty");
        require(_price > 0, "Price can not be nul");
        require(_plantingDate != 0, "_plantingDate can not be nul");
        require(bytes(_location).length != 0, "_location can not be empty");
        require(bytes(_locationOwnerName).length != 0, "_locationOwnerName can not be empty");
        require(bytes(_locationOwnerAddress).length != 0, "_locationOwnerAddress can not be empty");

        nextTokenTreeId++;

        TokenTree memory tokenTree = TokenTree({id: nextTokenTreeId, 
                                                species: _species, 
                                                purchaseDate: block.timestamp, 
                                                price: _price, 
                                                plantingDate: _plantingDate, 
                                                location: _location, 
                                                locationOwnerName: _locationOwnerName, 
                                                locationOwnerAddress: _locationOwnerAddress});

        nextTokenTreeKey = getLastAvailableTokenTreeKey() + 1;
        availableTokenTrees[nextTokenTreeKey] = tokenTree;
        ++availableTokenTreeCount;
    }

    ///@notice Get available tokens/trees mapping last key
    function getLastAvailableTokenTreeKey() public view returns (uint) {

        uint i = 1;
        while (availableTokenTrees[i].id > 0) {
            ++i;
        }

        return --i;
    }

    ///@notice Remove a token/tree from collection
    function removeAvailableTokenTree(uint _tokenTreeId) internal {
        
        require(availableTokenTrees[_tokenTreeId].id > 0, string.concat("Token tree not found. Token tree Id ", Strings.toString(_tokenTreeId), " does not exists"));
        delete availableTokenTrees[_tokenTreeId];

        // Recalibrate token/tree keys (avoid "blank" tokens/trees in the mapping)
        for(uint i = _tokenTreeId; i < availableTokenTreeCount; i++) {

            availableTokenTrees[i] = availableTokenTrees[i+1];

        }
        
        delete availableTokenTrees[availableTokenTreeCount];

        // Decrement token count
        --availableTokenTreeCount;
    }

    ///@notice Remove a token/tree from collection (admin)
    function removeAvailableTokenTreeAdmin(uint _tokenTreeId) external onlyOwner {
        removeAvailableTokenTree(_tokenTreeId);                
    }

    ///@notice Update an available token/tree
    function updateTokenTree(uint _tokenTreeId, string memory _species, uint _price, uint _plantingDate, string memory _location, 
                                string memory _locationOwnerName, string memory _locationOwnerAddress) external onlyOwner {

        require(availableTokenTrees[_tokenTreeId].id > 0, string.concat("Token tree not found. Token tree Id ", Strings.toString(_tokenTreeId), " does not exists"));
        require(bytes(_species).length != 0, "_species can not be empty");
        require(_price > 0, "Price can not be nul");
        require(_plantingDate != 0, "_plantingDate can not be nul");
        require(bytes(_location).length != 0, "_location can not be empty");
        require(bytes(_locationOwnerName).length != 0, "_locationOwnerName can not be empty");
        require(bytes(_locationOwnerAddress).length != 0, "_locationOwnerAddress can not be empty");

        TokenTree memory tokenTree = TokenTree({id: _tokenTreeId, 
                                                species: _species, 
                                                purchaseDate: block.timestamp, 
                                                price: _price, 
                                                plantingDate: _plantingDate, 
                                                location: _location, 
                                                locationOwnerName: _locationOwnerName, 
                                                locationOwnerAddress: _locationOwnerAddress});

        availableTokenTrees[_tokenTreeId] = tokenTree;

    }


    ///@notice Get tokens/trees available for bying
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
        require(msg.value == availableTokenTrees[_tokenTreeId].price, string.concat("Incorrect amount", ", sent : ", Strings.toString(msg.value), 
                                                                        ", current price is ", Strings.toString(availableTokenTrees[_tokenTreeId].price)));
        _mint(msg.sender, 1);

        uint nextCustomerTokenTreeKey = getLastCustomerTokenTreeKey(msg.sender) + 1;
        customersTokenTreeCollections[msg.sender][nextCustomerTokenTreeKey] = availableTokenTrees[_tokenTreeId];
        removeAvailableTokenTree(_tokenTreeId);
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

