// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

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
        uint id;
        string species;
        uint price;
        uint plantingDate;
        string location;
        string locationOwnerName;
        string locationOwnerAddress;
    }

    uint public availableTokenTreeCount;
    uint lastAvailableTokenTreeKey;
    uint lastAvailableTokenTreeId;

    ///@notice The token/tree collection being available for buying
    mapping(uint tokenTreeId => TokenTree) availableTokenTrees;

    ///@notice The token/tree collection of each customer
    mapping(address customer => mapping(uint customerTokenTreeKey => TokenTree customerTokenTreeCollection)) customersTokenTreeCollections;

    event AvailableTokenTreeAdded(uint id, string species, uint price, uint plantingDate, 
                                string location, string locationOwnerName, string locationOwnerAddress);
    event AvailableTokenTreeRemoved(address purchaser, uint tokenTreeId);
    event AvailableTokenTreeRemovedByAdmin(uint tokenTreeId);
    event AvailableTokenTreeUpdated(uint id, string species, uint price, uint plantingDate, 
                                string location, string locationOwnerName, string locationOwnerAddress);
    event TokenTreePurchased(address purchaser, uint tokenTreeId);
    event TokenTreeTransferred(uint tokenTreeId, address to);
    event TokenTreeTransferredFrom(uint tokenTreeId, address from, address to);


    ///@notice Add a token/tree in the available tokens/trees mapping
    function addTokenTree (string memory _species, uint _price, uint _plantingDate, string memory _location, 
                    string memory _locationOwnerName, string memory _locationOwnerAddress) external onlyOwner {
        
        require(bytes(_species).length != 0, "Species can not be empty");
        require(_price > 0, "Price can not be nul");
        require(_plantingDate != 0, "Planting date can not be nul");
        require(bytes(_location).length != 0, "Location can not be empty");
        require(bytes(_locationOwnerName).length != 0, "Location owner name can not be empty");
        require(bytes(_locationOwnerAddress).length != 0, "Location owner address can not be empty");

        lastAvailableTokenTreeId++;

        TokenTree memory tokenTree = TokenTree({id: lastAvailableTokenTreeId, 
                                                species: _species, 
                                                price: _price, 
                                                plantingDate: _plantingDate, 
                                                location: _location, 
                                                locationOwnerName: _locationOwnerName, 
                                                locationOwnerAddress: _locationOwnerAddress});

        lastAvailableTokenTreeKey++;
        availableTokenTrees[lastAvailableTokenTreeKey] = tokenTree;

        availableTokenTreeCount++;

        emit AvailableTokenTreeAdded(lastAvailableTokenTreeId, _species, _price, _plantingDate, _location, _locationOwnerName, _locationOwnerAddress);
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

        // Decrement token count and last key
        availableTokenTreeCount--;
        lastAvailableTokenTreeKey--;

        emit AvailableTokenTreeRemoved(msg.sender, _tokenTreeId);
    }

    ///@notice Remove a token/tree from collection (admin)
    function removeAvailableTokenTreeAdmin(uint _tokenTreeId) external onlyOwner {
        removeAvailableTokenTree(_tokenTreeId);                
        emit AvailableTokenTreeRemovedByAdmin(_tokenTreeId);
    }

    ///@notice Update an available token/tree
    function updateTokenTree(uint _tokenTreeId, string memory _species, uint _price, uint _plantingDate, string memory _location, 
                                string memory _locationOwnerName, string memory _locationOwnerAddress) external onlyOwner {

        require(availableTokenTrees[_tokenTreeId].id > 0, string.concat("Token tree not found. Token tree Id ", Strings.toString(_tokenTreeId), " does not exists"));
        require(bytes(_species).length != 0, "Species can not be empty");
        require(_price > 0, "Price can not be nul");
        require(_plantingDate != 0, "Planting date can not be nul");
        require(bytes(_location).length != 0, "Location can not be empty");
        require(bytes(_locationOwnerName).length != 0, "Location owner name can not be empty");
        require(bytes(_locationOwnerAddress).length != 0, "Location owner address can not be empty");

        TokenTree memory tokenTree = TokenTree({id: _tokenTreeId, 
                                                species: _species, 
                                                price: _price, 
                                                plantingDate: _plantingDate, 
                                                location: _location, 
                                                locationOwnerName: _locationOwnerName, 
                                                locationOwnerAddress: _locationOwnerAddress});

        availableTokenTrees[_tokenTreeId] = tokenTree;
        
        emit AvailableTokenTreeUpdated(_tokenTreeId, _species, _price, _plantingDate, _location, _locationOwnerName, _locationOwnerAddress);

    }

    ///@notice Get a customer tokens/trees collection
    function getCustomerTokenTrees() external view returns(TokenTree[] memory) {

        uint lastCustomerTokenTreeKey = getLastCustomerTokenTreeKey(msg.sender);
        TokenTree[] memory tmpCustomerTokenTrees = new TokenTree[](lastCustomerTokenTreeKey + 1);

        for(uint i = 1; i <= lastCustomerTokenTreeKey; i++) {
            
            tmpCustomerTokenTrees[i] = customersTokenTreeCollections[msg.sender][i];

        }

        return tmpCustomerTokenTrees;
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
        
        require(availableTokenTrees[_tokenTreeId].id > 0, string.concat("Token tree not found. Token tree Id ", Strings.toString(_tokenTreeId), " is not available"));
        require(msg.value == availableTokenTrees[_tokenTreeId].price, string.concat("Incorrect amount", ", sent : ", Strings.toString(msg.value), 
                                                                        ", current price is ", Strings.toString(availableTokenTrees[_tokenTreeId].price)));
        _mint(msg.sender, 1);

        uint nextCustomerTokenTreeKey = getLastCustomerTokenTreeKey(msg.sender) + 1;
        customersTokenTreeCollections[msg.sender][nextCustomerTokenTreeKey] = availableTokenTrees[_tokenTreeId];
        removeAvailableTokenTree(_tokenTreeId);

        emit TokenTreePurchased(msg.sender, _tokenTreeId);
    }

    ///@notice Get the last key in a customer token/tree mapping = the key of the last token/tree they own (NOT the token/tree id, the mapping key)
    function getLastCustomerTokenTreeKey(address _customer) internal view returns (uint) {

        uint i = 1;
        while (customersTokenTreeCollections[_customer][i].id > 0) {
            ++i;
        }

        return --i;
    }

    //notice Transfer a token/tree
    function transfer (address _to, uint _tokenTreeId) public override returns (bool) {

        require(customersTokenTreeCollections[msg.sender][_tokenTreeId].id > 0, 
                string.concat("Token tree not found.Token tree Id ", Strings.toString(_tokenTreeId), " does not exist in your collection"));

        // Transfer token
        _transfer(msg.sender, _to, 1);

        //Transfer token tree
        uint nextCustomerTokenTreeKey = getLastCustomerTokenTreeKey(_to) + 1;
        customersTokenTreeCollections[_to][nextCustomerTokenTreeKey] = customersTokenTreeCollections[msg.sender][_tokenTreeId];
        removeCustomerTokenTree(msg.sender, _tokenTreeId);

        emit TokenTreeTransferred(_tokenTreeId, _to);

        return true;
    }

    //notice Transfer a token/tree from an owner to a recipient
    function transferFrom (address _from, address _to, uint256 _tokenTreeId) public override returns (bool) {

        require(customersTokenTreeCollections[_from][_tokenTreeId].id > 0, 
                string.concat("Token tree not found.Token tree Id ", Strings.toString(_tokenTreeId), " does not exist in sender collection"));

        // Transfer token
        _spendAllowance(_from, msg.sender, 1);
        _transfer(_from, _to, 1);

        //Transfer token tree
        uint nextCustomerTokenTreeKey = getLastCustomerTokenTreeKey(_to) + 1;
        customersTokenTreeCollections[_to][nextCustomerTokenTreeKey] = customersTokenTreeCollections[_from][_tokenTreeId];
        removeCustomerTokenTree(_from, _tokenTreeId);

        emit TokenTreeTransferredFrom(_tokenTreeId, _from, _to);

        return true;
    }

    ///@notice Remove a token/tree from a customer collection
    function removeCustomerTokenTree(address _customer, uint _tokenTreeId) internal {
        
        delete customersTokenTreeCollections[_customer][_tokenTreeId];

        uint lastCustomerTokenTreeKey = getLastCustomerTokenTreeKey(_customer);

        // Recalibrate token/tree keys (avoid "blank" tokens/trees in the mapping)
        for(uint i = _tokenTreeId; i < lastCustomerTokenTreeKey; i++) {

            customersTokenTreeCollections[_customer][i] = customersTokenTreeCollections[_customer][i+1];

        }
        
        delete customersTokenTreeCollections[_customer][lastCustomerTokenTreeKey];

    }

}

