//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./contract-utils/UniswapV2Library.sol";
import "./interfaces/uniswap/IUniswapV2Router02.sol";
import "./interfaces/uniswap/IUniswapV2Pair.sol";
import "./interfaces/uniswap/IUniswapV2Factory.sol";
import "./contract-utils/Governable.sol";
import "./contract-utils/Manageable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract MultipleBuyerAndSender is Governable, Manageable {
    //+-We use SafeMath to Improve Security:_
    using SafeMath for uint256;

    string public name = "Multiple Buyer and Sender";
    //+-We connect the S.C. with the UniSwapV2 tools and Info:_
    address public UniSwapV2;
    address[] public AddressesWhiteList;
    address public fromToken;
    address public toToken;

    constructor(address _governor, address _UniSwapV2) public {
        require(_governor != address(0), 'governable/governor-should-not-be-zero-address');
        governor = _governor;
        UniSwapV2 = _UniSwapV2;
    }

    function AddAddressToWhiteList(address newAddress) public returns(address[] memory){  
        AddressesWhiteList.push(newAddress);
    
        return AddressesWhiteList;  
    }

    function DeleteAddressFromWhiteList(address ToDeleteAddress) public returns(address[] memory){ 
        uint256 _i = 0;

        while (AddressesWhiteList[_i] != ToDeleteAddress) {
            _i++;
            if(AddressesWhiteList[_i] == ToDeleteAddress){
                delete AddressesWhiteList[_i];
            }
        }

        return AddressesWhiteList;  
    }

    function SeeAddressesWhiteList() view pure {
        console.log(AddressesWhiteList);
    }

    //+-Set the Address of the Smart Contracts of the Tokens that are going to be Swapped:_
    function setSwapPair(address _fromToken, address _toToken) public {
        fromToken = _fromToken;
        toToken = _toToken;
    }

    //+-Swapping Tokens:_
    function startSwap(
        address token0, /**+-Token to give S.Contract Address. Ex:_ WETH.*/
        address token1, /**+-Token to receive S.Contract Address. Ex:_ DAI.*/
        uint256 amount0 /**+-Amount of the Asset "token0" that we want to Swap in the Transaction.*/
    ) external {
        //+-It looks for the Coin Pair in UniSwap:_
        address pairAddress =
            IUniswapV2Factory(UniSwapV2).getPair(token0, token1);
        //+-You have to make sure that the Coin Pair actually exists in UniSwap:_
        require(pairAddress != address(0), "This pool does not exist");
    }
}

contract EthSwap {
    address public fromToken;
    address public toToken;
    //+-Mapping to take account of the Buyers who have already purchased toTokens and are Waiting to Withdraw them from the S.C.:_
    mapping(address => uint) internal Buyers;

    event TokensDeposited(
        address account,
        address fromToken,
        uint amount
    );

    event TokensWithdrawn(
        address account,
        address toToken,
        uint amount
    );

    constructor(address _exchangeSmartContract) public {
        exchangeSmartContract = _exchangeSmartContract;
    }

    //+-Set the Address of the Smart Contracts of the Tokens that are going to be Swapped:_
    function setSwapPair(address _fromToken, address _toToken) public {
        fromToken = _fromToken;
        toToken = _toToken;
    }

    //+-The User Deposits the Amount of fromTokens that is going to Swap:_
    function provide(uint _amount) public payable {
        //+-Checks that the User actually has that amount of Tokens in his/her Wallet:_
        //require(IERC20(fromToken).balanceOf(msg.sender) >= _amount);
        //+-(We don't need to implement this because the ERC-20 Standard already does it).

        //+-The User Deposits the Token in the S.C.:_
        IERC20(fromToken).transferFrom(msg.sender, address(this), _amount);

        //+-Now that our contract owns fromTokens, we need to approve the UniSwapRouter to Withdraw them:_
        IERC20(fromToken).approve(UNISWAP_V2_ROUTER, _amount);

        //+-We issue a notice that the fromTokens have been Deposited:_
        emit TokensDeposited(msg.sender, fromToken, _amount);
    }

    function swap(uint256 _fromTokensAmount) public {
        //+-Tenga una función swap(uint256 _amount) que use los provided fromTokens previamente Swappearlos por toTokens en UniSwapV2.
        //+-We check that the UniSwapRouter actually is able to Withdraw the fromTokens for performing the Swap:_
        require(IERC20(fromToken).approve(UNISWAP_V2_ROUTER, _fromTokensAmount));

        //+-"path" is a List of Token Addresses that we want this Trade to Happen:_
        address[] memory path;
        path = new address[](2);
        path[0] = fromToken;
        //+-(We could have an "IntermediateToken" here just in case it would be a better deal to first Swap "fromToken" to "IntermediateToken" and then Swap it for "toToken").
        path[1] = toToken;

        //+-The S.C. performs the Swap with UniSwapV2Router:_
        IUniswapV2Router01(UNISWAP_V2_ROUTER).swapExactTokensForTokens(_fromTokensAmount, 0, path, address(this), block.timestamp);

        //+-If the Swap with UniSwapV2Router was Successful, when the "toTokens" are Deposited in the Exchange S.C. we assign that amount of "toTokens" to the Buyer:_
        //require(IUniswapV2Router01(address(IUniswapV2Router01)).swapExactTokensForTokens(_fromTokensAmount, 0, path, address(this), block.timestamp));
        //Buyers[msg.sender] = _toTokensAmount;
    }

    function  withdraw(uint256 _amount) public {//+-En esta función El Usuario debería poder retirar SOLO una Cantidad <= a Cantidad de toTokens que compró. 
        //+-Checks that the S.C. actually has that amount of Tokens Available:_
        require(IERC20(toToken).balanceOf(address(this)) >= _amount);

        //+-Checks that the User actually bought and is Owner of that amount of toTokens:_
        require(Buyers[msg.sender] <= _amount);

        //+-The User Withdraws the Token from the S.C.:_
        IERC20(toToken).transferFrom(address(this), msg.sender, _amount);

        //+-We discount the from the List the "toTokens" that the User has in the S.C.:_
        Buyers[msg.sender] = Buyers[msg.sender] - _amount;

        //+-We issue a notice that the toTokens have been Withdrawn:_
        emit TokensWithdrawn(msg.sender, toToken, _amount);
    }
}