// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin-3.2.0/contracts/token/ERC20/ERC20.sol";

/** @title MockERC20.
 * @notice It is a mock contract to replace ARN tokens in tests.
 */
contract MockERC20 is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 supply
    ) public ERC20(name, symbol) {
        _mint(msg.sender, supply);
    }

    // Mint Mock tokens to anyone requesting with a max of 1000 tokens
    function mintTokens(uint256 _amount) external {
        require(_amount < 1000000000000000000001, "1000 tokens max"); // 1000 tokens
        _mint(msg.sender, _amount);
    }
}
