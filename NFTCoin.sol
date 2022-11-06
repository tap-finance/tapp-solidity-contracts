// contracts/NFTCoin.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract NFTCoin is Initializable, ERC20Upgradeable, IERC721Receiver {
    mapping(uint256 => address) idOwners;

    address watch_addr;

    function initialize(string memory name, string memory symbol, address NFTAddr) public virtual initializer {
        __ERC20_init(name, symbol);
        watch_addr = NFTAddr;
    }


    function onERC721Received(address, address, uint256, bytes calldata)
    override
    public
    returns(bytes4)
    {
        return IERC721Receiver.onERC721Received.selector;
    }

    function depositNFT(uint256[] memory nftIds)
    public
    {
        ERC721 nft = ERC721(watch_addr);
        for(uint i=0; i<nftIds.length; i++){
            require(nft.ownerOf(nftIds[i]) == msg.sender);
        }

        for(uint i=0; i<nftIds.length; i++){
            nft.safeTransferFrom(msg.sender,address(this),nftIds[i]);
            idOwners[nftIds[i]] = msg.sender;
        }

        _mint(msg.sender,nftIds.length);

    }

    function redeemToken(uint256[] memory nftIds)
    public
    {
        ERC721 nft = ERC721(watch_addr);
        require(balanceOf(msg.sender) >= nftIds.length);
        for(uint i=0; i<nftIds.length; i++){
            require(idOwners[nftIds[i]] == msg.sender);
        }
        for(uint i=0; i<nftIds.length; i++){
            nft.safeTransferFrom(address(this),msg.sender,nftIds[i]);
            delete idOwners[nftIds[i]];
        }
        _burn(msg.sender,nftIds.length);

    }
}