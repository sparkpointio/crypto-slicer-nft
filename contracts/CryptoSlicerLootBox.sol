pragma solidity ^0.5.0;

import "./TradeableERC721Token.sol";
import "./CryptoSlicer.sol";
import "./Factory.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title CryptoSlicerLootBox
 *
 * CryptoSlicerLootBox - a tradeable loot box of Crypto Slicers.
 */
contract CryptoSlicerLootBox is TradeableERC721Token {
    uint256 NUM_CRYPTO_SLICERS_PER_BOX = 5;
    uint256 OPTION_ID = 0;
    address factoryAddress;

    constructor(address _proxyRegistryAddress, address _factoryAddress) TradeableERC721Token("CryptoSlicerLootBox", "LOOTBOX", _proxyRegistryAddress) public {
        factoryAddress = _factoryAddress;
    }

    function unpack(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender);

        // Insert custom logic for configuring the item here.
        for (uint256 i = 0; i < NUM_CRYPTO_SLICERS_PER_BOX; i++) {
            // Mint the ERC721 item(s).
            Factory factory = Factory(factoryAddress);
            factory.mint(OPTION_ID, msg.sender);
        }

        // Burn the presale item.
        _burn(msg.sender, _tokenId);
    }

    function baseTokenURI() public view returns (string memory) {
        return "https://sparkpointio.github.io/api/game/cryptoslicer/factory/box/";
    }

    function itemsPerLootbox() public view returns (uint256) {
        return NUM_CRYPTO_SLICERS_PER_BOX;
    }
}