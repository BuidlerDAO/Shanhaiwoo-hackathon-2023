// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin-3.2.0/contracts/access/Ownable.sol";
import "@openzeppelin-3.2.0/contracts/math/SafeMath.sol";
import "@openzeppelin-3.2.0/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin-3.2.0/contracts/token/ERC20/SafeERC20.sol";

import "./HAEquipments.sol";

contract HAMintingFactoryV2 is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    HAEquipments public haEquipments;
    IERC20 public arnToken;

    // end block number to get collectibles
    uint256 public endBlockNumber;

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
     * @dev A maximum number of NFT tokens that is distributed by this contract
     * is defined as totalSupplyDistributed.
     */
    constructor(
        HAEquipments _haEquipments,
        IERC20 _arnToken,
        uint256 _tokenPrice,
        string memory _ipfsHash,
        uint256 _startBlockNumber,
        uint256 _endBlockNumber
    ) public {
        haEquipments = _haEquipments;
        arnToken = _arnToken;
        tokenPrice = _tokenPrice;
        ipfsHash = _ipfsHash;
        startBlockNumber = _startBlockNumber;
        endBlockNumber = _endBlockNumber;
    }

    /**
     * @dev Mint NFTs from the HAEquipments contract.
     * Users can specify what equipId they want to mint. Users can claim once.
     * There is a limit on how many are distributed. It requires token balance to be > 0.
     */
    function mintNFT(uint8 _equipId) external {
        // Check _msgSender() has not claimed
        require(!hasClaimed[_msgSender()], "Has claimed");
        // Check block time is not too late
        require(block.number > startBlockNumber, "too early");
        // Check block time is not too late
        require(block.number < endBlockNumber, "too late");
        // Check that the _equipId is within boundary:
        require(_equipId >= previousNumberEquipIds && _equipId < numberEquipIds, "equipId too low or too high");

        // Update that _msgSender() has claimed
        hasClaimed[_msgSender()] = true;

        // Send ARN tokens to this contract
        arnToken.safeTransferFrom(address(_msgSender()), address(this), tokenPrice);

        string memory tokenURI = equipIdURIs[_equipId];

        uint256 tokenId = haEquipments.mint(address(_msgSender()), tokenURI, _equipId);

        emit EquipMint(_msgSender(), tokenId, _equipId);
    }

    /**
     * @dev It transfers the ownership of the NFT contract
     * to a new address.
     */
    function changeOwnershipNFTContract(address _newOwner) external onlyOwner {
        haEquipments.transferOwnership(_newOwner);
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
     * @dev Set up names for equips 5-9
     * Only the owner can set it.
     */
    function setEquipNames(
        string calldata _equipId5,
        string calldata _equipId6,
        string calldata _equipId7,
        string calldata _equipId8,
        string calldata _equipId9
    ) external onlyOwner {
        haEquipments.setEquipName(5, _equipId5);
        haEquipments.setEquipName(6, _equipId6);
        haEquipments.setEquipName(7, _equipId7);
        haEquipments.setEquipName(8, _equipId8);
        haEquipments.setEquipName(9, _equipId9);
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
     * @dev Allow to set up the end block number
     * Only the owner can set it.
     */
    function setEndBlockNumber(uint256 _newEndBlockNumber) external onlyOwner {
        require(_newEndBlockNumber > block.number, "too short");
        require(_newEndBlockNumber > startBlockNumber, "must be > startBlockNumber");
        endBlockNumber = _newEndBlockNumber;
    }

    /**
     * @dev Allow to change the token price
     * Only the owner can set it.
     */
    function updateTokenPrice(uint256 _newTokenPrice) external onlyOwner {
        tokenPrice = _newTokenPrice;
    }
}