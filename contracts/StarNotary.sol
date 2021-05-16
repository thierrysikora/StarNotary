// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {
    struct Star {
        string name;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo; // mapping the Star with the Owner Address
    mapping(uint256 => uint256) public starsForSale; // mapping the TokenId and price

    constructor() ERC721("stars of the universe", "STAR") {}

    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public {
        // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 price) public {
        require(
            ownerOf(_tokenId) == msg.sender,
            "You can't sale the Star you don't own"
        );
        starsForSale[_tokenId] = price;
    }

    function buyStar(uint256 _tokenId) public payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);

        require(msg.value >= starCost, "You need to have enough Ether");
        //safeTransferFrom(ownerAddress, msg.sender, _tokenId); (probably better but needs the owner to approve the buyer beforehand)
        _transfer(ownerAddress, msg.sender, _tokenId);
        address payable ownerAddressPayable = payable(ownerAddress);
        ownerAddressPayable.transfer(starCost);
        if (msg.value > starCost) {
            address payable payeeAddressPayable = payable(msg.sender);
            payeeAddressPayable.transfer(msg.value - starCost);
        }
        starsForSale[_tokenId] = 0;
    }

    // Implement Task 1 lookUptokenIdToStarInfo
    function lookUptokenIdToStarInfo(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        //1. You should return the Star saved in tokenIdToStarInfo mapping
        return tokenIdToStarInfo[_tokenId].name;
    }

    // Implement Task 1 Exchange Stars function
    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        //1. Passing to star tokenId you will need to check if the owner of _tokenId1 or _tokenId2 is the sender
        //2. You don't have to check for the price of the token (star)
        //3. Get the owner of the two tokens (ownerOf(_tokenId1), ownerOf(_tokenId1)
        //4. Use _transferFrom function to exchange the tokens.

        require(
            msg.sender == ownerOf(_tokenId1) ||
                msg.sender == ownerOf(_tokenId2),
            "You have to be the owner of one of the star"
        );
        address ownerOfToken1 = ownerOf(_tokenId1);
        address ownerOfToken2 = ownerOf(_tokenId2);
        _transfer(ownerOfToken1, ownerOfToken2, _tokenId1);
        _transfer(ownerOfToken2, ownerOfToken1, _tokenId2);
    }

    // Implement Task 1 Transfer Stars
    function transferStar(address _to1, uint256 _tokenId) public {
        require(
            msg.sender == ownerOf(_tokenId),
            "You can't transfer a Star you don't own"
        );
        _transfer(msg.sender, _to1, _tokenId);
        //1. Check if the sender is the ownerOf(_tokenId)
        //2. Use the transferFrom(from, to, tokenId); function to transfer the Star
    }
}
