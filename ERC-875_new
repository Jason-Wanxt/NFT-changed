//import "../math/SafeMath.sol";
//import "../math/SafeMath.sol";
pragma solidity ^0.6.0;
import "../math/SafeMath.sol";
import "../utils/EnumerableSet.sol";
interface ERC165 
{
            /// @notice Query if a contract implements an interface
            /// @param interfaceID The interface identifier, as specified in ERC-165
            /// @dev Interface identification is specified in ERC-165. This function
            ///  uses less than 30,000 gas.
            /// @return `true` if the contract implements `interfaceID` and
            ///  `interfaceID` is not 0xffffffff, `false` otherwise
            function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

abstract contract ERC875 /* is ERC165 */
{
  event Transfer(address indexed _from, address indexed _to, uint256[] tokenIndices);
  function name() view public virtual returns (string memory);
  function symbol() view public virtual returns (string memory);
  function balanceOf(address _owner) public virtual view returns (uint256[] memory);
  function transfer(address _to, uint256[] memory _tokens) public virtual;
  function transferFrom(address _from, address _to, uint256[] memory _tokens) public virtual;

  //optional
  function totalSupply() public view virtual returns (uint256);
  //function trade(uint256 expiryTimeStamp, uint256[] memory tokenIndices, uint8 v, bytes32 r, bytes32 s) public payable virtual;
  //function ownerOf(uint256 _tokenId) public view returns (address _owner);
}


contract Token is ERC875
{
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    
    uint public totalTickets;
    mapping(address => EnumerableSet.UintSet) inventory;
    mapping(uint256 => address) tokenOwners;
    //uint16 ticketIndex = 0; //to track mapping in tickets
    //uint expiryTimeStamp;
    address owner;   // the address that calls selfdestruct() and takes fees
    mapping(address => bool) public store;
    mapping(address => bool) public admin;
    uint transferFee;
    uint numOfTransfers = 0;
    string private _name;
    string private _symbol;
    uint8 public constant decimals = 0; //no decimals as tickets cannot be split
    mapping (uint256 => string) private _tokenURIs;
    mapping (uint256 => bool) private sold;

    event Transfer(address indexed _from, address indexed _to, uint256[] tokenIndices);
    event TransferFrom(address indexed _from, address indexed _to, uint _value);
    event TicketSold(uint256 indexed,address to);
    
    modifier adminOnly()
    {
        require(admin[msg.sender] == true,"ERC875:Only admin can do this");
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner,"ERC875:Only owner can do this");
        _;
    }
    
    modifier onlyUnsold(uint256 id) {
        require(sold[id] == false,"ERC875:The ticket has been sold");
        _;
    }
    
    modifier onlyStore() {
        require(store[msg.sender] == true,"ERC875:Only store can do this");
        _;
    }

    fallback() external{ revert(); } //should not send any ether directly

    // example: 10, "MJ comeback", "MJC"
    constructor(uint256 TokensNumber,
                string memory evName,
                string memory eventSymbol) public
    {
        owner = msg.sender;
        admin[owner] = true;
        mint(TokensNumber,msg.sender);
        _symbol = eventSymbol;
        _name = evName;
    }
    
    function grantAdmin(address to) public onlyOwner {
        require(msg.sender == owner,"ERC875:Only owner can do this");
        require(admin[to] != true,"ERC875：This address has already be admin");
        admin[to] = true;
    }
    
     function dropAdmin(address to) public onlyOwner {
        require(msg.sender == owner,"ERC875:Only owner can do this");
        require(admin[to] == true,"ERC875：This address should not be admin");
        admin[to] = false;
    }
    
    function grantStore(address to) public onlyOwner {
        require(msg.sender == owner,"ERC875:Only owner can do this");
        require(store[to] != true,"ERC875：This address has already be store");
        store[to] = true;
    }
    
     function dropStore(address to) public onlyOwner {
        require(msg.sender == owner,"ERC875:Only owner can do this");
        require(store[to] == true,"ERC875：This address should not be store");
        store[to] = false;
    }
    
    //mint okensNumber nfts, and send to ${to}
    function mint(uint256 TokensNumber,address to) adminOnly public {
        //address to = msg.sender;
        require(TokensNumber <= 50,"ERC875：Should be less than 50");
        EnumerableSet.UintSet storage balance = inventory[to];
        for(uint i = 0; i < TokensNumber; i++) {
            //balance[length++] = totalTickets + i;
            balance.add(totalTickets + i + 1);
            tokenOwners[totalTickets + i + 1] = to;
        }
        totalTickets = totalTickets.add(TokensNumber);
        
    }
    
    function sellTo(address to, string memory url) onlyStore public {
        mint(1,to);
        uint256 ticketId = totalTickets;
        _decorate(ticketId,url);
        sold[ticketId] = true;
        emit TicketSold(ticketId,to);
    }
    
    //put url to nft, but only if the nft has not been sold
    function  _decorate(uint256 tokensId, string memory url) private onlyUnsold(tokensId) {
        _tokenURIs[tokensId] = url;
    }
    
    function getUrl(uint256 tokenId) view public returns(string memory) {
        require(tokenOwners[tokenId] == msg.sender,"ERC875:You do not have this token");
        return _tokenURIs[tokenId];
    }
    
    function tokenUrl(uint256 tokenId) view public returns(string memory) {
        return getUrl(tokenId);
    }
    
    function totalSupply() public view override returns (uint256){
        return totalTickets;
    }

    function getDecimals() public pure returns(uint)
    {
        return decimals;
    }


    function name() public override view returns(string memory)
    {
        return _name;
    }

    function symbol() public override view returns(string memory)
    {
        return _symbol;
    }

    function getAmountTransferred() public view returns (uint)
    {
        return numOfTransfers;
    }



    function balanceOf(address _owner) public override view returns (uint256[] memory)
    {
        
        return getTokenByAddr(_owner);
    }
    
    function getTokenByAddr(address addr) view public returns(uint256[] memory)  {
        require(addr == msg.sender || admin[msg.sender] == true,"ERC875:Only admin or address self can call this func");
        EnumerableSet.UintSet storage set = inventory[addr];
        uint256 length = EnumerableSet.length(set);
        uint256[] memory res = new  uint256[](length);
        for(uint256 i = 0; i < length; i++) {
            res[i] = EnumerableSet.at(set,i);
        }
        return res;
    }

    function myBalance() public view returns(uint256[] memory)
    {
        return getTokenByAddr(msg.sender);
    }

    function transfer(address _to, uint256[] memory tokenIndices) public override
    {
        for(uint i = 0; i < tokenIndices.length; i++)
        {
            // require(inventory[msg.sender][i] != 0,"you dont have enough tokens");
            // //pushes each element with ordering
            // uint index = uint(tokenIndices[i]);
            // inventory[_to].push(tokenIndices[i]);
            // inventory[msg.sender][index] = 0;
            _transfer(msg.sender,_to,tokenIndices[i]);
        }
    }
    


    function _transfer(address _from, address _to,uint256 tokenIndices) internal {
        uint256 tokenId = EnumerableSet.at(inventory[_from],tokenIndices);
        require(tokenOwners[tokenId] == _from, "ERC875: transfer of token that is not belong to the sender");
        require(_to != address(0), "ERC875:Can not transfer to the zero address");
        inventory[_from].remove(tokenId);
        inventory[_to].add(tokenId);
        tokenOwners[tokenId] = _to;
    }

    function transferFrom(address _from, address _to, uint256[] memory tokenIndices)
        adminOnly public override
    {
        for(uint i = 0; i < tokenIndices.length; i++)
        {
            _transfer(_from,_to,tokenIndices[i]);
        }
    }

    function endContract() public
    {
        // if(msg.sender == owner)
        // {
        //     selfdestruct(msg.sender);
        // }
        // else revert();
        require(msg.sender == owner,"not owners");
        selfdestruct(msg.sender);
    }

    function getContractAddress() public view returns(address)
    {
        return address(this);
    }
}
