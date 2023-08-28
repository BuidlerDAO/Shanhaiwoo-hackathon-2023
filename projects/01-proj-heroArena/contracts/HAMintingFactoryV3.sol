// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin-3.2.0/contracts/access/Ownable.sol";
import "@openzeppelin-3.2.0/contracts/math/SafeMath.sol";
import "@openzeppelin-3.2.0/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin-3.2.0/contracts/token/ERC20/SafeERC20.sol";

import "./HAMintingFactoryV2.sol";
import "./HAMintingStation.sol";

/** @title HAMintingFactoryV3.
 * @notice It is a contract for users to mint 'starter NFTs'.
 */
contract BunnyFactoryV3 is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    HAMintingFactoryV2 public haMintingFactoryV2;
    HAMintingStation public haMintingFactoryV1Free;

    IERC20 public arnToken;

    // starting block
    uint256 public startBlockNumber;

    // Number of ARNs a user needs to pay to acquire a token
    uint256 public tokenPrice;

    // Map if address has already claimed a NFT
    mapping(address => bool) public hasClaimed;

    // IPFS hash for new json
    string private ipfsHash;

    // number of total series (i.e. different visuals)
    uint8 private constant numberEquipIds = 10;

    // number of previous series (i.e. different visuals)
    uint8 private constant previousNumberEquipIds = 5;

    // Map the token number to URI
    mapping(uint8 => string) private equipIdURIs;

    // Event to notify when NFT is successfully minted
    event EquipMint(address indexed to, uint256 indexed tokenId, uint8 indexed equipId);

    /**
     * @dev
     */
    constructor(
        HAMintingFactoryV2 _haMintingFactoryV2,
        HAMintingStation _haMintingFactoryV1Free,
        IERC20 _arnToken,
        uint256 _tokenPrice,
        string memory _ipfsHash,
        uint256 _startBlockNumber
    ) public {
        haMintingFactoryV2 = _haMintingFactoryV2;
        haMintingFactoryV1Free = _haMintingFactoryV1Free;
        arnToken = _arnToken;
        tokenPrice = _tokenPrice;
        ipfsHash = _ipfsHash;
        startBlockNumber = _startBlockNumber;
    }

    /**
     * @dev Mint NFTs from the HAMintingStation.sol contract.
     * Users can specify what equipId they want to mint. Users can claim once.
     */
    function mintNFT(uint8 _equipId) external {
        address senderAddress = _msgSender();

        bool hasClaimedV2 = haMintingFactoryV2.hasClaimed(senderAddress);

        // Check if _msgSender() has claimed in previous factory
        require(!hasClaimedV2, "Has claimed in v2");
        // Check _msgSender() has not claimed
        require(!hasClaimed[senderAddress], "Has claimed");
        // Check block time is not too late
        require(block.number > startBlockNumber, "too early");
        // Check that the _equipId is within boundary:
        require(_equipId >= previousNumberEquipIds && _equipId < numberEquipIds, "equipId too low or too high");

        // Update that _msgSender() has claimed
        hasClaimed[senderAddress] = true;

        // Send ARN tokens to this contract
        arnToken.safeTransferFrom(senderAddress, address(this), tokenPrice);

        string memory tokenURI = equipIdURIs[_equipId];

        uint256 tokenId = haMintingFactoryV1Free.mintCollectible(senderAddress, tokenURI, _equipId);

        emit EquipMint(senderAddress, tokenId, _equipId);
    }

    /**
     * @dev It transfers the ARN tokens back to the chef address.
     * Only callable by the owner.
     */
    function claimFee(uint256 _amount) external onlyOwner {
        arnToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @dev Set up json extensions for equips 5-9
     * Assign tokenURI to look for each equipId in the mint function
     * Only the owner can set it.
     */
    function setEquipJson(
        string calldata _equipId5Json,
        string calldata _equipId6Json,
        string calldata _equipId7Json,
        string calldata _equipId8Json,
        string calldata _equipId9Json
    ) external onlyOwner {
        equipIdURIs[5] = string(abi.encodePacked(ipfsHash, _equipId5Json));
        equipIdURIs[6] = string(abi.encodePacked(ipfsHash, _equipId6Json));
        equipIdURIs[7] = string(abi.encodePacked(ipfsHash, _equipId7Json));
        equipIdURIs[8] = string(abi.encodePacked(ipfsHash, _equipId8Json));
        equipIdURIs[9] = string(abi.encodePacked(ipfsHash, _equipId9Json));
    }

    /**
     * @dev Allow to set up the start number
     * Only the owner can set it.
     */
    function setStartBlockNumber(uint256 _newStartBlockNumber) external onlyOwner {
        require(_newStartBlockNumber > block.number, "too short");
        startBlockNumber = _newStartBlockNumber;
    }

    /**
     * @dev Allow to change the token price
     * Only the owner can set it.
     */
    function updateTokenPrice(uint256 _newTokenPrice) external onlyOwner {
        tokenPrice = _newTokenPrice;
    }

    function canMint(address userAddress) external view returns (bool) {
        if ((hasClaimed[userAddress]) || (haMintingFactoryV2.hasClaimed(userAddress))) {
            return false;
        } else {
            return true;
        }
    }
}