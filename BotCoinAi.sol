// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title BotCoinAi (BOT) - ERC20 with initial supply + owner-only mint
contract BotCoinAi {
    // ERC20 basic state
    string public name = "BotCoinAi";
    string public symbol = "BOT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // ownership
    address public owner;

    // events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        uint256 initial = 1_000_000_000 * 10**uint256(decimals); // 1,000,000,000 tokens
        _mint(msg.sender, initial);
    }

    // ERC20 view functions
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function allowance(address tokenOwner, address spender) external view returns (uint256) {
        return _allowances[tokenOwner][spender];
    }

    // ERC20 transfer
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(from, msg.sender, currentAllowance - amount);
        _transfer(from, to, amount);
        return true;
    }

    // owner-only mint (exposed)
    function mint(address to, uint256 amount) external onlyOwner returns (bool) {
        _mint(to, amount);
        return true;
    }

    // internal transfer/mint/approve implementations
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from zero");
        require(to != address(0), "ERC20: transfer to zero");
        uint256 fromBal = _balances[from];
        require(fromBal >= amount, "ERC20: transfer amount exceeds balance");
        _balances[from] = fromBal - amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "ERC20: mint to zero");
        totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function _approve(address tokenOwner, address spender, uint256 amount) internal {
        require(tokenOwner != address(0), "ERC20: approve from zero");
        require(spender != address(0), "ERC20: approve to zero");
        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }

    // ownership helpers
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner zero");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
