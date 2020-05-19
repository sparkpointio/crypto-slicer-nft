pragma solidity ^0.5.0;

import "./TradeableERC721Token.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title CryptoSlicer
 * CryptoSlicer - a contract for SparkPoint's non-fungible Crypto Slicers (swords and knives).
 */
contract CryptoSlicer is TradeableERC721Token {
  constructor(address _proxyRegistryAddress) TradeableERC721Token("Crypto Slicer", "CSS", _proxyRegistryAddress) public {  }

  function baseTokenURI() public view returns (string memory) {
    return "https://sparkpointio.github.io/api/game/cryptoslicer/nft/";
  }

  function contractURI() public view returns (string memory) {
    return "https://sparkpointio.github.io/api/game/cryptoslicer/contract/";
  }
}
