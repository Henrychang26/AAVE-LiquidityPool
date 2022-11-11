//SPDC-License-Identifier: MIT

pragma solidity 0.8.10;


import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

contract MarketInteractions{
    //State Variables
    address payable owner;

    IPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
    IPool public immutable POOL;

    address private immutable linkAdress = 0x07C725d58437504CA5f814AE406e70E21C5e8e9e;
    IERC20 private link;

    constructor(address _addressProider){
        ADDRESSES_PROVIDER= IPoolAddressesProvider(_addressProider);
        POOL = IPool(ADDRESSES_PROVIDER.getPool());
        owner = payable(msg.sender);
        link = IERC20(linkAdress);
    }

    //Modifier

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    //Events

    event liquiditySupply(address asset, uint256 amount);
    event liduidityWithdrew(address asset, uint256 amount, address to);

    function supplyLiquidity(address _tokenAddress, uint256 _amount)external{
        //Uses suuply() from IPool.sol
        address asset = _tokenAddress;
        uint256 amount = _amount;
        address onBehalfOf = address(this);
        uint16 referralCode = 0;

        POOL.supply(asset, amount, onBehalfOf, referralCode);

        emit liquiditySupply(asset, amount);

    }

    function withdrawLiquidity(address _tokenAddress, uint256 _amount) external returns (uint256){
        address asset = _tokenAddress;
        uint256 amount = _amount;
        address to = address(this);

        return POOL.withdraw(asset, amount, to);
        emit liduidityWithdrew(asset, amount, to);
    }

    function getUserAccountData(address _userAddress) external view returns(
        uint256 totalCollateralBase,
        uint256 totalDebtBase,
        uint256 availableBorrowsBase,
        uint256 currentLiquidationThreshhold,
        uint256 ltv,
        uint256 healthFactor
        ){
            return POOL.getUserAccountData(_userAddress);
        
    }

    function approveLINK(uint256 _amount, address _poolContractAddress) external returns (bool){
        return link.approve(_poolContractAddress, _amount);
    }

    function allowanceLINK(address _poolContractAddress) external view returns(uint256){
        return link.allowance(address(this), _poolContractAddress);
    }

    function getBalance(address _tokenAddress) external view returns(uint256){
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    receive() external payable{}
}