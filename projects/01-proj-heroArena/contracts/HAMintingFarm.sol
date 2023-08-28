// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin-3.2.0/contracts/access/Ownable.sol";
import "@openzeppelin-3.2.0/contracts/math/SafeMath.sol";
import "@openzeppelin-3.2.0/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin-3.2.0/contracts/token/ERC20/SafeERC20.sol";

import "./HAEquipments.sol";

contract HAMintingFarm is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    HAEquipments public haEquipments;
    IERC20 public arnToken;

    // Map if address can claim a NFT
    mapping(address => bool) public canClaim;

    // Map if address has already claimed a NFT
    mapping(address => bool) public hasClaimed;

    // starting block
    uint256 public startBlockNumber;

    // end block number to claim ARNs by burning NFT
    uint256 public endBlockNumber;

    // number of total equips burnt
    uint256 public countEquipsBurnt;

    // Number of ARNs a user can collect by burning her NFT
    uint256 public arnPerBurn;

    // current distributed number of NFTs
    uint256 public currentDistributedSupply;

    // number of total NFTs distributed
    uint256 public totalSupplyDistributed;

    // baseURI (on IPFS)
    string private baseURI;

    // Map the token number to URI
    mapping(uint8 => string) private equipIdURIs;

    // number of initial series (i.e. different visuals)
    uint8 private numberOfEquipIds;

    // Event to notify when NFT is successfully minted
    event EquipMint(address indexed to, uint256 indexed tokenId, uint8 indexed equipId);

    // Event to notify when NFT is successfully minted
    event EquipBurn(address indexed from, uint256 indexed tokenId);

    /**
     * @dev A maximum number of NFT tokens that is distributed by this contract
     * is defined as totalSupplyDistributed.
     */
    constructor(
        IERC20 _arnToken,
        uint256 _totalSupplyDistributed,
        uint256 _arnPerBurn,
        string memory _baseURI,
        string memory _ipfsHash,
        uint256 _endBlockNumber
    ) public {
        haEquipments = new HAEquipments(_baseURI);
        arnToken = _arnToken;
        totalSupplyDistributed = _totalSupplyDistributed;
        arnPerBurn = _arnPerBurn;
        baseURI = _baseURI;
        endBlockNumber = _endBlockNumber;

        // Other parameters initialized
        numberOfEquipIds = 5;

        // Assign tokenURI to look for each equipId in the mint function
        equipIdURIs[0] = string(abi.encodePacked(_ipfsHash, "G-sword.json"));
        equipIdURIs[1] = string(abi.encodePacked(_ipfsHash, "G-bow.json"));
        equipIdURIs[2] = string(abi.encodePacked(_ipfsHash, "G-wand.json"));
        equipIdURIs[3] = string(abi.encodePacked(_ipfsHash, "G-stuff.json"));
        equipIdURIs[4] = string(abi.encodePacked(_ipfsHash, "G-broadsword.json"));

        // Set token names for each equipId
        haEquipments.setEquipName(0, "Genesys Sword");
        haEquipments.setEquipName(1, "Genesys Bow");
        haEquipments.setEquipName(2, "Genesys Wand");
        haEquipments.setEquipName(3, "Genesys Stuff");
        haEquipments.setEquipName(4, "Genesys Broadsword");
    }

    /**
     * @dev Mint NFTs from the HAEquipments contract.
     * Users can specify what equipId they want to mint. Users can claim once.
     * There is a limit on how many are distributed. It requires ARN balance to be >0.
     */
    function mintNFT(uint8 _equipId) external {
        // Check msg.sender can claim
        require(canClaim[msg.sender], "Cannot claim");
        // Check msg.sender has not claimed
        require(hasClaimed[msg.sender] == false, "Has claimed");
        // Check whether it is still possible to mint
        require(currentDistributedSupply < totalSupplyDistributed, "Nothing left");
        // Check whether user owns any ARN
        require(arnToken.balanceOf(msg.sender) > 0, "Must own ARN");
        // Check that the _equipId is within boundary:
        require(_equipId < numberOfEquipIds, "equipId unavailable");
        // Update that msg.sender has claimed
        hasClaimed[msg.sender] = true;

        // Update the currentDistributedSupply by 1
        currentDistributedSupply = currentDistributedSupply.add(1);

        string memory tokenURI = equipIdURIs[_equipId];

        uint256 tokenId = haEquipments.mint(address(msg.sender), tokenURI, _equipId);

        emit EquipMint(msg.sender, tokenId, _equipId);
    }

    /**
     * @dev Burn NFT from the HAEquipments contract.
     * Users can burn their NFT to get a set number of ARN.
     * There is a cap on how many can be distributed for free.
     */
    function burnNFT(uint256 _tokenId) external {
        require(haEquipments.ownerOf(_tokenId) == msg.sender, "Not the owner");
        require(block.number < endBlockNumber, "too late");

        haEquipments.burn(_tokenId);
        countEquipsBurnt = countEquipsBurnt.add(1);
        arnToken.safeTransfer(address(msg.sender), arnPerBurn);
        emit EquipBurn(msg.sender, _tokenId);
    }

    /**
     * @dev Allow to set up the start number
     * Only the owner can set it.
     */
    function setStartBlockNumber() external onlyOwner {
        startBlockNumber = block.number;
    }

    /**
     * @dev Allow the contract owner to whitelist addresses.
     * Only these addresses can claim.
     */
    function whitelistAddresses(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            canClaim[users[i]] = true;
        }
    }

    /**
     * @dev It transfers the ARN tokens back to the chef address.
     * Only callable by the owner.
     */
    function withdrawCake(uint256 _amount) external onlyOwner {
        require(block.number >= endBlockNumber, "too early");
        arnToken.safeTransfer(address(msg.sender), _amount);
    }

    /**
     * @dev It transfers the ownership of the NFT contract
     * to a new address.
     */
    function changeOwnershipNFTContract(address _newOwner) external onlyOwner {
        haEquipments.transferOwnership(_newOwner);
    }
}