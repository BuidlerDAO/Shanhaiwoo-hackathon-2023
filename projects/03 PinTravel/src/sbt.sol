pragma solidity ^0.8.0;

contract SBT {
    // 景区 ID
    struct Scene {
        uint256 id;
        string name;
        string description;
    }

    // SBT 纪念证明
    struct SBTProof {
        uint256 sceneId;
        string location;
        uint256 timestamp;
        bytes image;
    }

    // SBT 合约地址
    address public owner;

    // 景区列表
    mapping(uint256 => Scene) private scenes;

    // SBT 纪念证明列表
    mapping(uint256 => SBTProof) private proofs;

    // 构造函数
    constructor() {
        owner = msg.sender;
    }

    // 添加景区
    function addScene(string memory name, string memory description) public {
        require(msg.sender == owner, "只有合约所有者才能添加景区");

        uint256 sceneId = scenes.length;
        scenes[sceneId] = Scene({
            id: sceneId,
            name: name,
            description: description,
        });
    }

    // 生成 SBT 纪念证明
    function generateSBTProof(uint256 sceneId, string memory location, bytes memory image) public {
        require(sceneId > 0, "景区 ID 必须大于 0");
        require(location.length > 0, "地理位置必须不为空");
        require(image.length > 0, "照片必须不为空");

        SBTProof memory proof = SBTProof({
            sceneId: sceneId,
            location: location,
            timestamp: block.timestamp,
            image: image,
        });

        proofs[proof.id] = proof;
    }

    // 获取所有景区
    function getScenes() public view returns (Scene[] memory) {
        return scenes;
    }

    // 获取 SBT 纪念证明
    function getSBTProof(uint256 proofId) public view returns (SBTProof memory) {
        return proofs[proofId];
    }
}