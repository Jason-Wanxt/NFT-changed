pragma solidity 0.6;

import "./ITicketStore.sol";
import "./github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC875.sol";
import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/ChainlinkClient.sol";
import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "./github/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";

contract TicketStore is ITicketStore, ChainlinkClient {
    Token nft;
    using SafeMath for uint256;
    using SafeMath for int256;
    
    
    event ChangeTicketAddr(string,address);
    event ChangeTicketFee(string,uint256);
    
    uint num;
    uint public balance;
    uint256 public ethPrice;
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    uint256 public ticketFee;
    AggregatorV3Interface internal priceFeed;
    mapping(address => bool) public admin;
    address public Owner;
    
    //fallback() external{ revert(); } //should not send any ether directly
    
    constructor(address _nft) public {
        nft = Token(_nft);
        //setPublicChainlinkToken();
        oracle = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;
        jobId = "29fa9aa13bf1468788b7cc4a500a45b8";
        priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        Owner = msg.sender;
        admin[Owner] = true;
    }
    
    modifier onlyOwner {
        require(msg.sender == Owner,"Only Owner can do this");
        _;
    }
    
    modifier onlyAdmin {
        require(admin[msg.sender] == true,"Only admin can do this");
        _;
    }
    
    function setTicketFee(uint256 _fee) onlyAdmin public {
        ticketFee = _fee;
        ChangeTicketFee("The ticket fee changed",_fee);
    }
    
    function setTicketAddr(address addr) onlyAdmin public {
        nft = Token(addr);
        ChangeTicketAddr("The ticket addr changed",addr);
    }
    
    function grantAdmin(address to) public onlyOwner {
        require(msg.sender == Owner,"ERC875:Only owner can do this");
        require(admin[to] != true,"ERC875：This address has already be admin");
        admin[to] = true;
    }
    
     function dropAdmin(address to) public onlyOwner {
        require(msg.sender == Owner,"ERC875:Only owner can do this");
        require(admin[to] == true,"ERC875：This address should not be admin");
        admin[to] = false;
    }
    
    function getETHPriceUSD() public view override returns(int256){
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        // If the round is not complete yet, timestamp is 0
        require(timeStamp > 0, "Round not complete");
        return price;
    }
    
    
    function buyTicket(address to) payable public override returns(bool) {
        // uint256 ethFee = uint256(getETHPriceUSD());
        // uint256 ethN = 10**18 wei;
        // uint256 price = ethN.div(ethFee,"");//every ticket cost 1 dollar
        uint256 price = ticketFee;
        //check if the sender give enough eth,if not,send back those eth
        if(msg.value < price) {
            msg.sender.transfer(msg.value);
            revert("TicketStore:you did not sender enough eth");
        } else {
            msg.sender.transfer(msg.value - price);
            _transferTicketByMint(to,"{time:any time}");
            balance += price;
            return true;
        }
    }
    
    function buyTicketByCenter(address to,string memory url) onlyAdmin public override returns(bool) {
        _transferTicketByMint(to,url);
        return true;
    }
    
    // function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) override external returns (bytes4){
    //     return 0;
    // }
    
    function withdraw() onlyOwner public payable {
        msg.sender.transfer(balance);
        balance = 0;
    }
    
    function _transferTicketByMint(address to, string memory url) internal {
        nft.sellTo(to,url);
    }
}
