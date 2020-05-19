pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Factory.sol";
import "./CryptoSlicer.sol";
import "./CryptoSlicerLootBox.sol";
import "./Strings.sol";

contract CryptoSlicerFactory is Factory, Ownable {
  using Strings for string;

  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

  address public proxyRegistryAddress;
  address public nftAddress;
  address public lootBoxNftAddress;
  string public baseURI = "https://sparkpointio.github.io/api/game/cryptoslicer/factory/";

  /**
   * Enforce the existence of only 5500 Crypto Slicers.
   */
  uint256 CRYPTO_SLICER_SUPPLY = 5500;

  /**
   * Three different options for minting Crypto Slicers (basic, premium, and gold).
   */
  uint256 NUM_OPTIONS = 3;
  uint256 SINGLE_CRYPTO_SLICER_OPTION = 0;
  uint256 MULTIPLE_CRYPTO_SLICER_OPTION = 1;
  uint256 LOOTBOX_OPTION = 2;
  uint256 NUM_CRYPTO_SLICERS_IN_MULTIPLE_CRYPTO_SLICER_OPTION = 4;

  constructor(address _proxyRegistryAddress, address _nftAddress) public {
    proxyRegistryAddress = _proxyRegistryAddress;
    nftAddress = _nftAddress;
    lootBoxNftAddress = address(new CryptoSlicerLootBox(_proxyRegistryAddress, address(this)));

    fireTransferEvents(address(0), owner());
  }

  function name() external view returns (string memory) {
    return "SparkPoint Crypto Slicer Item Sale";
  }

  function symbol() external view returns (string memory) {
    return "CSF";
  }

  function supportsFactoryInterface() public view returns (bool) {
    return true;
  }

  function numOptions() public view returns (uint256) {
    return NUM_OPTIONS;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    address _prevOwner = owner();
    super.transferOwnership(newOwner);
    fireTransferEvents(_prevOwner, newOwner);
  }

  function fireTransferEvents(address _from, address _to) private {
    for (uint256 i = 0; i < NUM_OPTIONS; i++) {
      emit Transfer(_from, _to, i);
    }
  }

  function mint(uint256 _optionId, address _toAddress) public {
    // Must be sent from the owner proxy or owner.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    assert(address(proxyRegistry.proxies(owner())) == msg.sender || owner() == msg.sender || msg.sender == lootBoxNftAddress);
    require(canMint(_optionId));

    CryptoSlicer cryptoSlicer = CryptoSlicer(nftAddress);
    if (_optionId == SINGLE_CRYPTO_SLICER_OPTION) {
      cryptoSlicer.mintTo(_toAddress);
    } else if (_optionId == MULTIPLE_CRYPTO_SLICER_OPTION) {
      for (uint256 i = 0; i < NUM_CRYPTO_SLICERS_IN_MULTIPLE_CRYPTO_SLICER_OPTION; i++) {
        cryptoSlicer.mintTo(_toAddress);
      }
    } else if (_optionId == LOOTBOX_OPTION) {
      CryptoSlicerLootBox cryptoSlicerLootBox = CryptoSlicerLootBox(lootBoxNftAddress);
      cryptoSlicerLootBox.mintTo(_toAddress);
    }
  }

  function canMint(uint256 _optionId) public view returns (bool) {
    if (_optionId >= NUM_OPTIONS) {
      return false;
    }

    CryptoSlicer cryptoSlicer = CryptoSlicer(nftAddress);
    uint256 cryptoSlicerSupply = cryptoSlicer.totalSupply();

    uint256 numItemsAllocated = 0;
    if (_optionId == SINGLE_CRYPTO_SLICER_OPTION) {
      numItemsAllocated = 1;
    } else if (_optionId == MULTIPLE_CRYPTO_SLICER_OPTION) {
      numItemsAllocated = NUM_CRYPTO_SLICERS_IN_MULTIPLE_CRYPTO_SLICER_OPTION;
    } else if (_optionId == LOOTBOX_OPTION) {
      CryptoSlicerLootBox cryptoSlicerLootBox = CryptoSlicerLootBox(lootBoxNftAddress);
      numItemsAllocated = cryptoSlicerLootBox.itemsPerLootbox();
    }
    return cryptoSlicerSupply < (CRYPTO_SLICER_SUPPLY - numItemsAllocated);
  }

  function tokenURI(uint256 _optionId) external view returns (string memory) {
    return Strings.strConcat(
        baseURI,
        Strings.uint2str(_optionId)
    );
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use transferFrom so the frontend doesn't have to worry about different method names.
   */
  function transferFrom(address _from, address _to, uint256 _tokenId) public {
    mint(_tokenId, _to);
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
   */
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    public
    view
    returns (bool)
  {
    if (owner() == _owner && _owner == _operator) {
      return true;
    }

    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (owner() == _owner && address(proxyRegistry.proxies(_owner)) == _operator) {
      return true;
    }

    return false;
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
   */
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return owner();
  }
}
