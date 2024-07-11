// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title CARB-B Token contract
/// @author JF Briche
/// @notice The token represents a tree that will be planted in a field
contract CarbB is ERC20, Ownable {

    constructor() ERC20("CARBONTREE B", "CARB-B") Ownable(msg.sender) {}

    using Strings for uint;

    /// @notice The token tree properties
    struct TokenTree {
        uint key;
        uint treeId;
        string species;
        uint price;
        uint plantingDate;
        string location;
        string locationOwnerName;
        string locationOwnerAddress;}

    uint public availableTokenTreeCount;
    uint lastAvailableTokenTreeKey;
    uint lastAvailableTokenTreeId;

    ///@notice The token/tree collection being available for buying
    mapping(uint tokenTreeKey => TokenTree) availableTokenTrees;

    ///@notice The token/tree collection of each customer
    mapping(address customer => mapping(uint customerTokenTreeKey => TokenTree customerTokenTreeCollection)) customersTokenTreeCollections;

    ///@notice Emitted when an available token/tree is added
    event AvailableTokenTreeAdded(uint key, uint treeId, string species, uint price, uint plantingDate, 
                                string location, string locationOwnerName, string locationOwnerAddress);
    ///@notice Emitted when an available token/tree is removed
    event AvailableTokenTreeRemoved(address purchaser, uint tokenTreeKey);
    ///@notice Emitted when an available token/tree is removed by admin
    event AvailableTokenTreeRemovedByAdmin(uint tokenTreeKey);
    ///@notice Emitted when an available token/tree is updated
    event AvailableTokenTreeUpdated(uint key, uint treeId, string species, uint price, uint plantingDate, 
                                string location, string locationOwnerName, string locationOwnerAddress);
    ///@notice Emitted when an available token/tree is purchased
    event TokenTreePurchased(address purchaser, uint tokenTreeKey);
    ///@notice Emitted when a customer token/tree is transfered    
    event TokenTreeTransferred(uint tokenTreeKey, address to);
    ///@notice Emitted when a customer token/tree is transfered with allowance     
    event TokenTreeTransferredFrom(uint tokenTreeKey, address from, address to);


    /// @notice Add a token/tree in the available tokens/trees mapping
    /// @param _species The tree species
    /// @param _price The tree price
    /// @param _plantingDate The tree planting date
    /// @param _location The tree location
    /// @param _locationOwnerName The tree location owner first name and last name
    /// @param _locationOwnerAddress The address of the tree location owner 
    function addTokenTree (string memory _species, uint _price, uint _plantingDate, string memory _location, 
                    string memory _locationOwnerName, string memory _locationOwnerAddress) external onlyOwner {
        
        require(bytes(_species).length != 0, "Species can not be empty");
        require(_price > 0, "Price can not be nul");
        require(_plantingDate != 0, "Planting date can not be nul");
        require(bytes(_location).length != 0, "Location can not be empty");
        require(bytes(_locationOwnerName).length != 0, "Location owner name can not be empty");
        require(bytes(_locationOwnerAddress).length != 0, "Location owner address can not be empty");

        lastAvailableTokenTreeId++;
        lastAvailableTokenTreeKey++;
        
        TokenTree memory tokenTree = TokenTree({key: lastAvailableTokenTreeKey,
                                                treeId: lastAvailableTokenTreeId, 
                                                species: _species, 
                                                price: _price, 
                                                plantingDate: _plantingDate, 
                                                location: _location, 
                                                locationOwnerName: _locationOwnerName, 
                                                locationOwnerAddress: _locationOwnerAddress});
        
        availableTokenTrees[lastAvailableTokenTreeKey] = tokenTree;

        availableTokenTreeCount++;

        emit AvailableTokenTreeAdded(lastAvailableTokenTreeKey, lastAvailableTokenTreeId, _species, _price, _plantingDate, _location, _locationOwnerName, _locationOwnerAddress);
    }

    ///@notice Remove a token/tree from collection
    ///@param _tokenTreeKey The available token/tree key
    function removeAvailableTokenTree(uint _tokenTreeKey) internal {
        
        require(availableTokenTrees[_tokenTreeKey].key > 0, string.concat("Token tree not found. Token tree key ", Strings.toString(_tokenTreeKey), " does not exists"));
        delete availableTokenTrees[_tokenTreeKey];

        // Recalibrate token/tree keys (avoid "blank" tokens/trees in the mapping)
        for(uint i = _tokenTreeKey; i < availableTokenTreeCount; i++) {

            availableTokenTrees[i] = availableTokenTrees[i+1];
            availableTokenTrees[i].key = i;
        }
        
        delete availableTokenTrees[availableTokenTreeCount];

        // Decrement token count and last key
        availableTokenTreeCount--;
        lastAvailableTokenTreeKey--;

        emit AvailableTokenTreeRemoved(msg.sender, _tokenTreeKey);
    }

    ///@notice Remove a token/tree from collection (admin)
    ///@param _tokenTreeKey The available token/tree key
    function removeAvailableTokenTreeAdmin(uint _tokenTreeKey) external onlyOwner {
        removeAvailableTokenTree(_tokenTreeKey);                
        emit AvailableTokenTreeRemovedByAdmin(_tokenTreeKey);
    }

    ///@notice Update an available token/tree
    ///@param _tokenTreeKey The token/tree key
    ///@param _species The tree species
    ///@param _price The tree price
    ///@param _plantingDate The tree planting date
    ///@param _location The tree location
    ///@param _locationOwnerName The tree location owner first name and last name
    ///@param _locationOwnerAddress The address of the tree location owner 
    function updateTokenTree(uint _tokenTreeKey, string memory _species, uint _price, uint _plantingDate, string memory _location, 
                                string memory _locationOwnerName, string memory _locationOwnerAddress) external onlyOwner {

        require(availableTokenTrees[_tokenTreeKey].key > 0, string.concat("Token tree not found. Token tree key ", Strings.toString(_tokenTreeKey), " does not exists"));
        require(bytes(_species).length != 0, "Species can not be empty");
        require(_price > 0, "Price can not be nul");
        require(_plantingDate != 0, "Planting date can not be nul");
        require(bytes(_location).length != 0, "Location can not be empty");
        require(bytes(_locationOwnerName).length != 0, "Location owner name can not be empty");
        require(bytes(_locationOwnerAddress).length != 0, "Location owner address can not be empty");

        uint treeId = availableTokenTrees[_tokenTreeKey].treeId;

        TokenTree memory tokenTree = TokenTree({key: _tokenTreeKey,
                                                treeId: treeId, 
                                                species: _species, 
                                                price: _price, 
                                                plantingDate: _plantingDate, 
                                                location: _location, 
                                                locationOwnerName: _locationOwnerName, 
                                                locationOwnerAddress: _locationOwnerAddress});

        availableTokenTrees[_tokenTreeKey] = tokenTree;
        
        emit AvailableTokenTreeUpdated(_tokenTreeKey, _tokenTreeKey, _species, _price, _plantingDate, _location, _locationOwnerName, _locationOwnerAddress);

    }

    ///@notice Get a customer tokens/trees collection
    ///@return TokenTree[] An array of TokenTree structures containing the caller token/tree collection
    function getCustomerTokenTrees() external view returns(TokenTree[] memory) {

        uint lastCustomerTokenTreeKey = getLastCustomerTokenTreeKey(msg.sender);
        TokenTree[] memory tmpCustomerTokenTrees = new TokenTree[](lastCustomerTokenTreeKey + 1);

        for(uint i = 1; i <= lastCustomerTokenTreeKey; i++) {
            
            tmpCustomerTokenTrees[i] = customersTokenTreeCollections[msg.sender][i];

        }

        return tmpCustomerTokenTrees;
    }

    ///@notice Get tokens/trees available for bying
    ///@return TokenTree[] An array of TokenTree structures containing the available token/tree collection
    function getAvailableTokenTrees() external view returns(TokenTree[] memory) {

        TokenTree[] memory tmpAvailableTokenTrees = new TokenTree[](availableTokenTreeCount + 1);

        for(uint i = 1; i <= availableTokenTreeCount; i++) {
            
            tmpAvailableTokenTrees[i] = availableTokenTrees[i];

        }

        return tmpAvailableTokenTrees;
    }

    ///@notice Buy a token/tree and add it in the customer tree collection
    ///@param _tokenTreeKey The key of the token/tree to buy
    function buy (uint _tokenTreeKey ) external payable {
        
        require(availableTokenTrees[_tokenTreeKey].key > 0, string.concat("Token tree not found. Token tree key ", Strings.toString(_tokenTreeKey), " is not available"));
        require(msg.value == availableTokenTrees[_tokenTreeKey].price, string.concat("Incorrect amount", ", sent : ", Strings.toString(msg.value), 
                                                                        ", current price is ", Strings.toString(availableTokenTrees[_tokenTreeKey].price)));
        _mint(msg.sender, 1);

        uint nextCustomerTokenTreeKey = getLastCustomerTokenTreeKey(msg.sender) + 1;
        customersTokenTreeCollections[msg.sender][nextCustomerTokenTreeKey] = availableTokenTrees[_tokenTreeKey];
        customersTokenTreeCollections[msg.sender][nextCustomerTokenTreeKey].key = nextCustomerTokenTreeKey;
        removeAvailableTokenTree(_tokenTreeKey);

        emit TokenTreePurchased(msg.sender, _tokenTreeKey);
    }

    ///@notice Get the last key in a customer token/tree mapping = the key of the last token/tree they own (NOT the token/tree id, the mapping key)
    ///@param _customer The customer address
    function getLastCustomerTokenTreeKey(address _customer) internal view returns (uint) {

        uint i = 1;
        while (customersTokenTreeCollections[_customer][i].key > 0) {
            ++i;
        }

        return --i;
    }

    ///@notice Transfer a token/tree
    ///@param _to The address of the recipient
    ///@param _tokenTreeKey The key of the token/tree to be transferred
    function transfer (address _to, uint _tokenTreeKey) public override returns (bool) {

        require(customersTokenTreeCollections[msg.sender][_tokenTreeKey].key > 0, 
                string.concat("Token tree not found.Token tree key ", Strings.toString(_tokenTreeKey), " does not exist in your collection"));

        // Transfer token
        _transfer(msg.sender, _to, 1);

        //Transfer token tree
        uint nextCustomerTokenTreeKey = getLastCustomerTokenTreeKey(_to) + 1;
        customersTokenTreeCollections[_to][nextCustomerTokenTreeKey] = customersTokenTreeCollections[msg.sender][_tokenTreeKey];
        customersTokenTreeCollections[_to][nextCustomerTokenTreeKey].key = nextCustomerTokenTreeKey;
        removeCustomerTokenTree(msg.sender, _tokenTreeKey);

        emit TokenTreeTransferred(_tokenTreeKey, _to);

        return true;
    }

    ///@notice Transfer a token/tree from an owner to a recipient
    ///@param _from The address of the owner of the token/tree to be transferred from
    ///@param _to The address of the recipient
    ///@param _tokenTreeKey The key of the token/tree to be transferred
    function transferFrom (address _from, address _to, uint256 _tokenTreeKey) public override returns (bool) {

        require(customersTokenTreeCollections[_from][_tokenTreeKey].key > 0, 
                string.concat("Token tree not found.Token tree key ", Strings.toString(_tokenTreeKey), " does not exist in sender collection"));

        // Transfer token
        _spendAllowance(_from, msg.sender, 1);
        _transfer(_from, _to, 1);

        //Transfer token tree
        uint nextCustomerTokenTreeKey = getLastCustomerTokenTreeKey(_to) + 1;
        customersTokenTreeCollections[_to][nextCustomerTokenTreeKey] = customersTokenTreeCollections[_from][_tokenTreeKey];
        customersTokenTreeCollections[_to][nextCustomerTokenTreeKey].key = nextCustomerTokenTreeKey;
        removeCustomerTokenTree(_from, _tokenTreeKey);

        emit TokenTreeTransferredFrom(_tokenTreeKey, _from, _to);

        return true;
    }

    ///@notice Remove a token/tree from a customer collection
    ///@param _customer The address of the token/tree collection owner
    ///@param _tokenTreeKey The key of the token/tree to be removed
    function removeCustomerTokenTree(address _customer, uint _tokenTreeKey) internal {
        
        delete customersTokenTreeCollections[_customer][_tokenTreeKey];

        uint lastCustomerTokenTreeKey = getLastCustomerTokenTreeKey(_customer);

        // Recalibrate token/tree keys (avoid "blank" tokens/trees in the mapping)
        for(uint i = _tokenTreeKey; i < lastCustomerTokenTreeKey; i++) {

            customersTokenTreeCollections[_customer][i] = customersTokenTreeCollections[_customer][i+1];
            customersTokenTreeCollections[_customer][i].key = i;

        }
        
        delete customersTokenTreeCollections[_customer][lastCustomerTokenTreeKey];

    }

    /// @notice Withdraw contract ethers (only owner)
    function withdraw() external onlyOwner {

        (bool success, )= msg.sender.call{value: address(this).balance}("");
        require (success, "Ether transfer failed");    
    }
}

