// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract LimaSmart is ERC721URIStorage {

    using Counters for Counters.Counter;
    //_tokenIds variable has the most recent minted tokenId(listed good)
    Counters.Counter private _tokenIds;
    //Keeps track of the number of goods sold
    Counters.Counter private _goodsSold;

    //boolean to approve 
     mapping(address => bool) public farmerApprove;
     mapping(address => bool)public retailerApprove;

    //mapping to store user wallet address
    mapping(address => bool) public farmerAddresses;
    mapping(address => bool) public retailerAddresses;

    //This mapping maps tokenId to good info and is helpful when retrieving details about a tokenId
    mapping(uint256 => ListedGood) private idToListedGood;


      //The structure to store info about a listed good
    struct ListedGood {
        uint256 newTokenId;
        address payable owner;
        uint256 price;
    }

     constructor() ERC721("LimaSmart", "LS") {
    }
    
    function registerFarmerAccount() public {
        //check if the address is already registered
        require(farmerAddresses[msg.sender]  == false, "Address already registered");

       //add the address to mapping
       farmerAddresses[msg.sender] = true;

        }

     function registerRetailerAccount() public {
        //check if the address is already registered
        require(retailerAddresses[msg.sender] == false, "Address already registered");

        //add the address to mapping
        retailerAddresses[msg.sender] = true;
        

    }

      //The first time a token is created, it is listed here
    function listGood(string memory tokenURI, uint256 price) public returns (uint) {
        //sanity check
        require(farmerAddresses[msg.sender] == true, "You ain't registered");
        require(price > 0, "Input price");

        //Increment the tokenId counter, which is keeping track of the number of minted NFTs(items listed)
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        //Mint the NFT with tokenId newTokenId to the address who called listGood function
        _safeMint(msg.sender, newTokenId);

        //Map the tokenId to the tokenURI (which is an IPFS URL with the NFT metadata)
        _setTokenURI(newTokenId, tokenURI);

       //Update the mapping of tokenId's to good details, useful for retrieval functions
        idToListedGood[newTokenId] = ListedGood(
            newTokenId,
            payable(msg.sender),
            price
        );


        return newTokenId;
    }

    function buyGoods(uint256 tokenId) public payable {
        uint price = idToListedGood[tokenId].price;

        require(retailerAddresses[msg.sender] == true, "Not registered as a retailer");
        require(msg.value == price, "Incorrect amount");
        
        //transfer money to escrow
        payable(address(this)).transfer(msg.value); 

    }

   

    function retailerApproval(bool approve) public {
       retailerApprove[msg.sender] = approve;
    }
    
    function executeSale(uint256 _tokenId) public payable {
        require(retailerApprove[msg.sender] == true, "Not approved ");

         //Transfer the proceeds from the sale to the farmer

        uint price = idToListedGood[_tokenId].price;
        address farmer = idToListedGood[_tokenId].owner;

        payable(farmer).transfer(price);


    }

}