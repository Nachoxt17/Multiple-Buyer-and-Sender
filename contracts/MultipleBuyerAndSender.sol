//SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

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
    address public UniSwapV2Factory;
    address public UniSwapV2Router;
    address[] public AddressesWhiteList;
    address[] public Receivers;
    address public fromToken;
    address public toToken;
    uint256 public numberOfTimesToBuy;

    event TokensDeposited(
        address account,
        address _token,
        uint amount
    );

    event TokensWithdrawn(
        address account,
        address _token,
        uint amount
    );

    constructor(address _firstWhiteListMember, address _UniSwapV2Factory, address _UniSwapV2Router) public {
        require(_firstWhiteListMember != address(0), 'WhiteList-Member-should-not-be-zero-address');
        AddressesWhiteList.push(_firstWhiteListMember);
        UniSwapV2Factory = _UniSwapV2Factory;
        UniSwapV2Router = _UniSwapV2Router;
    }

    function isWhiteListMember(address _account) public view returns (bool) {
        bool _isWhiteListMember = false;
        uint256 i;

        for (i = 0; _isWhiteListMember == false && i <= AddressesWhiteList.length; i++) {
            if(AddressesWhiteList[i] == _account){
                _isWhiteListMember = true;
            } else {
                _isWhiteListMember = false;
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
    function SeeAddressesWhiteList() public view onlyWhiteListMember returns(address[] memory) {
        return AddressesWhiteList;
    }

    //+-The User Deposits the Amount of fromTokens that is going to Swap:_
    function depositTokens(address _token, uint _amount) public payable onlyWhiteListMember {
        //+-The User Deposits the Token in the S.C.:_
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        //+-Now that our contract owns fromTokens, we need to approve the UniSwapRouter to Withdraw them:_
        IERC20(_token).approve(UniSwapV2Router, _amount);

        //+-We issue a notice that the fromTokens have been Deposited:_
        emit TokensDeposited(msg.sender, _token, _amount);
    }

    function  withdraw(address _token, uint256 _amount) public onlyWhiteListMember {
        //+-Checks that the S.C. actually has that amount of Tokens Available:_
        require(IERC20(_token).balanceOf(address(this)) >= _amount);

        //+-The User Withdraws the Token from the S.C.:_
        IERC20(_token).transferFrom(address(this), msg.sender, _amount);

        //+-We issue a notice that the toTokens have been Withdrawn:_
        emit TokensWithdrawn(msg.sender, _token, _amount);
    }

    //+-Set the Address of the Smart Contracts of the Tokens that are going to be Swapped:_
    function setSwapPair(address _fromToken, address _toToken) public onlyWhiteListMember {
        fromToken = _fromToken;
        toToken = _toToken;
    }

    //+-Set How many Times I want to buy Tokens in 1 Transaction:_
    function setAmountBuyTimes(uint256 _numberOfTimes) public onlyWhiteListMember {
        numberOfTimesToBuy = _numberOfTimes;
    }

    //+-Swapping Tokens:_
    /**+-uint256 _fromTokensAmount:_ Amount of fromTokens that we want to Swap in the Transaction.*/
    function swapTokens(
        uint256 _fromTokensAmount 
    ) public onlyWhiteListMember {
        //+-It looks for the Coin Pair in UniSwapFactory:_
        address pairAddress =
            IUniswapV2Factory(UniSwapV2Factory).getPair(fromToken, toToken);
        //+-You have to make sure that the Coin Pair actually exists in UniSwap:_
        require(pairAddress != address(0), "This pool does not exist");

        //+-We check that the UniSwapRouter actually is able to Withdraw the fromTokens for performing the Swap:_
        require(IERC20(fromToken).approve(UniSwapV2Router, _fromTokensAmount * numberOfTimesToBuy));

        //+-"path" is a List of Token Addresses with which we want this Trade to Happen:_
        address[] memory path;
        path = new address[](2);
        path[0] = fromToken;
        path[1] = toToken;

        //+-The S.C. performs the Swap with UniSwapV2Router:_
        IUniswapV2Router01(UniSwapV2Router).swapExactTokensForTokens(_fromTokensAmount * numberOfTimesToBuy, 0, path, address(this), block.timestamp);
    }

    //+-Add an Address to the ReceiversList:_
    function AddAddressToReceiversList(address newAddress) public onlyWhiteListMember returns(address[] memory){  
        Receivers.push(newAddress);
        return Receivers;
    }

    //+-Delete an Address from the ReceiversList:_
    function DeleteAddressFromReceiversList(address ToDeleteAddress) public onlyWhiteListMember returns(address[] memory){ 
        uint256 _i = 0;

        while (Receivers[_i] != ToDeleteAddress) {
            _i++;
            if(Receivers[_i] == ToDeleteAddress){
                delete Receivers[_i];
                break;
            }
        }

        return Receivers;  
    }

    //+-See all the Addresses in the ReceiversList:_
    function SeeAddressesReceiversList() public view onlyWhiteListMember returns(address[] memory) {
        return Receivers;
    }

    //+-Send the same Ammount of Tokens to all the Receivers at the same time:_
    function MultipleSender(address _token, uint256 _amount) public onlyWhiteListMember {
        //+-Checks that the S.C. actually has that amount of Tokens Available:_
        require(IERC20(_token).balanceOf(address(this)) >= _amount * Receivers.length);

        //+-The User Withdraws the Token from the S.C.:_
        IERC20(_token).transferFrom(address(this), msg.sender, _amount);
        uint256 j;
        for (j = 0; j < Receivers.length; j++) {
            IERC20(_token).transferFrom(address(this), Receivers[j], _amount);
        }
    }
}