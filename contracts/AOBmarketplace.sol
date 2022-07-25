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