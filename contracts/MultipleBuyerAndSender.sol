//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./contract-utils/UniswapV2Library.sol";
import "./interfaces/uniswap/IUniswapV2Router02.sol";
import "./interfaces/uniswap/IUniswapV2Pair.sol";
import "./interfaces/uniswap/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract MultipleBuyerAndSender {
    //+-We use SafeMath to Improve Security:_
    using SafeMath for uint256;

    string public name = "Multiple Buyer and Sender";
    //+-We connect the S.C. with the UniSwapV2 tools and Info:_
    address public UniSwapV2;
    address[] public AddressesWhiteList;
    address public fromToken;
    address public toToken;
    //+-Mapping to take account of the Buyers who have already purchased toTokens and are Waiting to Withdraw them from the S.C.:_
    mapping(address => uint) internal Buyers;

    event FromTokensDeposited(
        address account,
        address fromToken,
        uint amount
    );

    event fromTokensWithdrawn(
        address account,
        address fromToken,
        uint amount
    );

    event ToTokensWithdrawn(
        address account,
        address toToken,
        uint amount
    );

    constructor(address _firstWhiteListMember, address _UniSwapV2) public {
        require(_firstWhiteListMember != address(0), 'WhiteList-Member-should-not-be-zero-address');
        AddressesWhiteList.push(_firstWhiteListMember);
        UniSwapV2 = _UniSwapV2;
    }

    function isWhiteListMember(address _account) public view returns (bool _isWhiteListMember) {
        bool _isWhiteListMember = false;

        for (i = 0; _isWhiteListMember == false && i < AddressesWhiteList.lenght; i++) {
            if(AddressesWhiteList[i] == _account){
                isWhiteListMember = true;
            } else {
                isWhiteListMember = false;
            }
        }

        return _isWhiteListMember;
    }

    modifier onlyWhiteListMember {
        require(isWhiteListMember(msg.sender), 'Only-WhiteList-Members-Allowed.');
        _;
    }

    //+-Add an Address to the WhiteList:_
    function AddAddressToWhiteList(address newAddress) public onlyWhiteListMember returns(address[] memory){  
        AddressesWhiteList.push(newAddress);
        return AddressesWhiteList;
    }

    //+-Delete an Address from the WhiteList:_
    function DeleteAddressFromWhiteList(address ToDeleteAddress) public onlyWhiteListMember returns(address[] memory){ 
        uint256 _i = 0;

        while (AddressesWhiteList[_i] != ToDeleteAddress) {
            _i++;
            if(AddressesWhiteList[_i] == ToDeleteAddress){
                delete AddressesWhiteList[_i];
                break;
            }
        }

        return AddressesWhiteList;  
    }

    //+-See all the Addresses in the WhiteList:_
    function SeeAddressesWhiteList() view onlyWhiteListMember {
        console.log(AddressesWhiteList);
    }

    //+-The User Deposits the Amount of fromTokens that is going to Swap:_
    function depositTokens(uint _amount) public payable onlyWhiteListMember {
        //+-The User Deposits the Token in the S.C.:_
        IERC20(fromToken).transferFrom(msg.sender, address(this), _amount);

        //+-Now that our contract owns fromTokens, we need to approve the UniSwapRouter to Withdraw them:_
        IERC20(fromToken).approve(UNISWAP_V2_ROUTER, _amount);

        //+-We issue a notice that the fromTokens have been Deposited:_
        emit FromTokensDeposited(msg.sender, fromToken, _amount);
    }

    function  withdraw(uint256 _amount) public onlyWhiteListMember {//+-In this Function The User can withdraw ONLY an Amount of Tokens <= to the Amount of Tokens that Bought. 
        //+-Checks that the S.C. actually has that amount of Tokens Available:_
        require(IERC20(fromToken || toToken).balanceOf(address(this)) >= _amount);

        //+-Checks that the User actually bought and is Owner of that amount of toTokens:_
        require(Buyers[msg.sender] <= _amount);

        //+-The User Withdraws the Token from the S.C.:_
        IERC20(toToken).transferFrom(address(this), msg.sender, _amount);

        //+-We discount the from the List the "toTokens" that the User has in the S.C.:_
        Buyers[msg.sender] = Buyers[msg.sender] - _amount;

        //+-We issue a notice that the toTokens have been Withdrawn:_
        emit ToTokensWithdrawn(msg.sender, toToken, _amount);
    }

    //+-Set the Address of the Smart Contracts of the Tokens that are going to be Swapped:_
    function setSwapPair(address _fromToken, address _toToken) public onlyWhiteListMember {
        fromToken = _fromToken;
        toToken = _toToken;
    }

    //+-Swapping Tokens:_
    function swapTokens(
        uint256 _fromTokensAmount /**+-Amount of fromTokens that we want to Swap in the Transaction.*/
    ) public onlyWhiteListMember {
        //+-It looks for the Coin Pair in UniSwap:_
        address pairAddress =
            IUniswapV2Factory(UniSwapV2).getPair(fromToken, toToken);
        //+-You have to make sure that the Coin Pair actually exists in UniSwap:_
        require(pairAddress != address(0), "This pool does not exist");

        //+-We check that the UniSwapRouter actually is able to Withdraw the fromTokens for performing the Swap:_
        require(IERC20(fromToken).approve(UNISWAP_V2_ROUTER, _fromTokensAmount));

        //+-"path" is a List of Token Addresses with which we want this Trade to Happen:_
        address[] memory path;
        path = new address[](2);
        path[0] = fromToken;
        path[1] = toToken;

        //+-The S.C. performs the Swap with UniSwapV2Router:_
        IUniswapV2Router01(UNISWAP_V2_ROUTER).swapExactTokensForTokens(_fromTokensAmount, 0, path, address(this), block.timestamp);

        //+-If the Swap with UniSwapV2Router is Successful, when the "toTokens" are Deposited in the Exchange S.C. we assign that amount of "toTokens" to the Buyer:_
        require(IUniswapV2Router01(address(IUniswapV2Router01)).swapExactTokensForTokens(_fromTokensAmount, 0, path, address(this), block.timestamp));
        Buyers[msg.sender] = _toTokensAmount;
    }
}

/**
contract EthSwap {

    function swap(uint256 _fromTokensAmount) public {
        //+-We check that the UniSwapRouter actually is able to Withdraw the fromTokens for performing the Swap:_
        require(IERC20(fromToken).approve(UNISWAP_V2_ROUTER, _fromTokensAmount));

        //+-"path" is a List of Token Addresses with which we want this Trade to Happen:_
        address[] memory path;
        path = new address[](2);
        path[0] = fromToken;
        path[1] = toToken;

        //+-The S.C. performs the Swap with UniSwapV2Router:_
        IUniswapV2Router01(UNISWAP_V2_ROUTER).swapExactTokensForTokens(_fromTokensAmount, 0, path, address(this), block.timestamp);

        //+-If the Swap with UniSwapV2Router is Successful, when the "toTokens" are Deposited in the Exchange S.C. we assign that amount of "toTokens" to the Buyer:_
        require(IUniswapV2Router01(address(IUniswapV2Router01)).swapExactTokensForTokens(_fromTokensAmount, 0, path, address(this), block.timestamp));
        Buyers[msg.sender] = _toTokensAmount;
    }
}
*/