pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller,uint256 amountOfETH,uint256 amountOfTokens);

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // buy tokens from the vendor
  function buyTokens() public payable{
    uint256 tokens = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, tokens);

    emit BuyTokens(msg.sender, msg.value, tokens);
  }

  // function for the owner to withdraw from the contract
  function withdraw() public onlyOwner {
    require(address(this).balance > 0);

    uint256 amount = address(this).balance;

    payable(msg.sender).transfer(amount);
  }

  // sell token back to the vendor for ETH
function sellTokens(uint256 amount) public {
      require(amount > 0, "Specify the amount you want to sell");
      // require(yourToken.balanceOf(msg.sender) >= amount, "You do not have enough tokens to sell");
      
      require(
          yourToken.allowance(msg.sender, address(this)) >= amount,
          "Token allowance too low"
      );
      uint256 payout = amount / tokensPerEth;

      require(address(this).balance >= payout, "not enough ETH in the contract, try later");
      

      (bool success, ) = msg.sender.call{value: payout}("");
      require( success, "FAILED");
      // calling safeTransferFrom to transfer the fund
      _safeTransferFrom(yourToken, msg.sender, address(this), amount);

      emit SellTokens(msg.sender, payout, amount);
  }

  // transfer the founds
  function _safeTransferFrom(
      IERC20 token,
      address sender,
      address recipient,
      uint amount
  ) private {
      bool sent = token.transferFrom(sender, recipient, amount);
      require(sent, "Token transfer failed");
  }

}
