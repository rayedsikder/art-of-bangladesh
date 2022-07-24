// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AOBmarketplace is ERC721Royalty, ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => uint256) private _salePrice;

    uint256 private platformFee;

    string baseURI;

    constructor(uint256 platformFee_, string memory baseURI_) ERC721("AOBmarketplace", "AOB") {
        platformFee = platformFee_;
        baseURI = baseURI_;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }        

    function getPlatformFee() public view virtual returns (uint256) {
        return platformFee;
    }
    
    function withdraw(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "AOBmarketplace: Not enought balance");
        (bool sent, ) = owner().call{value: amount}("");
        require(sent, "Failed to send Ether");        
    }

    function createArt(address creator, string calldata uri, uint96 feeNumerator) external payable {
        require(msg.value >= platformFee, "AOBmarketplace: MSG.VALUE is not platformFee");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(creator, tokenId);
        _setTokenURI(tokenId, uri);
        _setTokenRoyalty(tokenId, creator, feeNumerator);
    }

    function buyArt(uint256 tokenId) external payable nonReentrant {
        
        uint256 salePrice = _salePrice[tokenId];
        (address receiver, uint256 royaltyAmount) = royaltyInfo(tokenId, salePrice);
        
        require(
            msg.value >= salePrice + royaltyAmount + platformFee, 
            "AOBmarketplace: MSG.VALUE is less than sale price"
        );
        
        safeTransferFrom(ownerOf(tokenId), _msgSender(), tokenId);
        
        (bool sent, ) = receiver.call{value: royaltyAmount}("");
        require(sent, "Failed to send Ether");
        
        address owner = ownerOf(tokenId);
        
        (sent, ) = owner.call{value: salePrice}("");
        require(sent, "Failed to send Ether");
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice) public view virtual override returns (address, uint256) {
        require(_exists(tokenId), "AOBmarketplace: Invalid Token Id");
        super.royaltyInfo(tokenId, salePrice);
    }

    function approveListing(uint256 tokenId, uint256 salePrice) public virtual {
        address owner = ERC721.ownerOf(tokenId);

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _salePrice[tokenId] = salePrice;
        _approve(address(this), tokenId);
    }

    function approve(address to, uint256 tokenId) public virtual override {
        require(to != address(this), "AOBmarketplace: Cannot approve marketplace without salePrice");
        
        super.approve(to, tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721Royalty, ERC721URIStorage) {
        super._burn(tokenId);
    }
    
}