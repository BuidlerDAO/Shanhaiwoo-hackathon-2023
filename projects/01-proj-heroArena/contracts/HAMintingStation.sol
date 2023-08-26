// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin-3.2.0/contracts/access/AccessControl.sol";
import "./HAEquipments.sol";

/** @title HAMintingStation.sol.
 * @dev This contract allows different factories to mint
 * Pancake Collectibles/Bunnies.
 */
contract HAMintingStation is AccessControl {
    HAEquipments public haEquipments;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Modifier for minting roles
    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, _msgSender()), "Not a minting role");
        _;
    }

    // Modifier for admin roles
    modifier onlyOwner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Not an admin role");
        _;
    }

    constructor(HAEquipments _haEquipments) public {
        haEquipments = _haEquipments;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @notice Mint NFTs from the HAEquipments contract.
     */
    function mintCollectible(
        address _tokenReceiver,
        string calldata _tokenURI,
        uint8 _equipId
    ) external onlyMinter returns (uint256) {
        uint256 tokenId = haEquipments.mint(_tokenReceiver, _tokenURI, _equipId);
        return tokenId;
    }

    /**
     * @notice Set up names for equips.
     * @dev Only the main admins can set it.
     */
    function setEquipName(uint8 _equipId, string calldata _equipName) external onlyOwner {
        haEquipments.setEquipName(_equipId, _equipName);
    }

    /**
     * @dev It transfers the ownership of the NFT contract to a new address.
     * @dev Only the main admins can set it.
     */
    function changeOwnershipNFTContract(address _newOwner) external onlyOwner {
        haEquipments.transferOwnership(_newOwner);
    }

}