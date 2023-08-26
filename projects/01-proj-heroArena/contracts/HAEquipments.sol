// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin-3.2.0/contracts/access/Ownable.sol";
import "@openzeppelin-3.2.0/contracts/utils/Counters.sol";
import "@openzeppelin-3.2.0/contracts/token/ERC721/ERC721.sol";

/** @title HAEquipments.sol.
 * @notice It is the contracts for HeroArena NFTs.
 */
contract HAEquipments is ERC721, Ownable {
    using Counters for Counters.Counter;

    // Map the number of tokens per equipId
    mapping(uint8 => uint256) public equipCount;

    // Map the number of tokens burnt per equipId
    mapping(uint8 => uint256) public equipBurnCount;

    // Used for generating the tokenId of new NFT minted
    Counters.Counter private _tokenIds;

    // Map the equipId for each tokenId
    mapping(uint256 => uint8) private equipIds;

    // Map the equipName for a tokenId
    mapping(uint8 => string) private equipNames;

    constructor(string memory _baseURI) public ERC721("HA Equipments", "HAE") {
        _setBaseURI(_baseURI);
    }

    /**
     * @dev Get equipId for a specific tokenId.
     */
    function getEquipId(uint256 _tokenId) external view returns (uint8) {
        return equipIds[_tokenId];
    }

    /**
     * @dev Get the associated equipName for a specific equipId.
     */
    function getEquipName(uint8 _equipId) external view returns (string memory) {
        return equipNames[_equipId];
    }

    /**
     * @dev Get the associated equipName for a unique tokenId.
     */
    function getEquipNameOfTokenId(uint256 _tokenId) external view returns (string memory) {
        uint8 equipId = equipIds[_tokenId];
        return equipNames[equipId];
    }

    /**
     * @dev Mint NFTs. Only the owner can call it.
     */
    function mint(
        address _to,
        string calldata _tokenURI,
        uint8 _equipId
    ) external onlyOwner returns (uint256) {
        uint256 newId = _tokenIds.current();
        _tokenIds.increment();
        equipIds[newId] = _equipId;
        equipCount[_equipId] = equipCount[_equipId].add(1);
        _mint(_to, newId);
        _setTokenURI(newId, _tokenURI);
        return newId;
    }

    /**
     * @dev Set a unique name for each equipId. It is supposed to be called once.
     */
    function setEquipName(uint8 _equipId, string calldata _name) external onlyOwner {
        equipNames[_equipId] = _name;
    }

    /**
     * @dev Burn a NFT token. Callable by owner only.
     */
    function burn(uint256 _tokenId) external onlyOwner {
        uint8 equipIdBurnt = equipIds[_tokenId];
        equipCount[equipIdBurnt] = equipCount[equipIdBurnt].sub(1);
        equipBurnCount[equipIdBurnt] = equipBurnCount[equipIdBurnt].add(1);
        _burn(_tokenId);
    }
}