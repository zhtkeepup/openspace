pragma solidity ^0.8.10;

import "forge-std/Test.sol";

contract Safe {
    receive() external payable {}

    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract SafeTest is Test {
    Safe safe;

    // Needed so the test contract itself can receive ether
    // when withdrawing
    receive() external payable {}

    function setUp() public {
        safe = new Safe();
    }

    function test_Withdraw() public {
        console.log("balance0:", address(safe).balance, address(this).balance);
        payable(address(safe)).transfer(1 ether);
        console.log("balance1:", address(safe).balance, address(this).balance);
        uint256 preBalance = address(this).balance;
        safe.withdraw();
        console.log("balance2:", address(safe).balance, address(this).balance);
        uint256 postBalance = address(this).balance;
        console.log("balance3:", address(safe).balance, address(this).balance);
        assertEq(preBalance + 1 ether, postBalance);
    }

    function test_fuzz_Withdraw(uint256 amount) public {
        // console.log("ttt:", Counter.test_fuzz_Withdraw.selector);
        vm.assume(amount < 100 ether);
        deal(address(this), 100 ether);
        payable(address(safe)).transfer(amount);
        uint256 preBalance = address(this).balance;
        safe.withdraw();
        uint256 postBalance = address(this).balance;
        assertEq(preBalance + amount, postBalance);
    }
}
