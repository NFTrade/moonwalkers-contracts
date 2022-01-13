pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ERC2981.sol";

contract MoonWalkers is ERC721Enumerable, ERC2981, Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    string public baseURI = "";
    string public defaultURI = "";
    uint256 public constant PRICE = 0.1 ether; // 0.1 GLMR
    uint public maxPerUser = 3;
    uint256 public MAX_SUPPLY = 2000;
    bool public saleIsActive = false;
    uint256 private royaltiesFees;
    address private royaltiesAddress;

    // mapping of address to amount
    mapping (address => uint256) public purchases;

    constructor(string memory name, string memory symbol, string memory _defaultURI)
        ERC721(name, symbol)
    {
        defaultURI = _defaultURI;
    }

    /** ADMIN */

    /// @dev change the base uri
    /// @param uri base uri
    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    /// @dev Pause sale if active, make active if paused
    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    /// @dev sets royalties address
    /// for 2981
    function setRoyaltiesAddress(address _royaltiesAddress)
        public
        onlyOwner
    {
        royaltiesAddress = _royaltiesAddress;
    }

    /// @dev sets royalties fees
    function setRoyaltiesFees(uint256 _royaltiesFees)
        public
        onlyOwner
    {
        royaltiesFees = _royaltiesFees;
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /// @inheritdoc	ERC721
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /// @inheritdoc	IERC2981
    function royaltyInfo(uint256 tokenId, uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        return (royaltiesAddress, value * royaltiesFees / 100);
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        string memory uri = super.tokenURI(tokenId);
        return bytes(uri).length > 0 ? uri : defaultURI;
    }

    /// @dev mint number of nfts
    /// @param amount the amount to mint
    function mint(uint256 amount)
        public
        payable
        nonReentrant
    {
        require(saleIsActive, "Sale must be active to mint");
        require(amount.add(purchases[msg.sender]) <= maxPerUser, "More than max per user");
        require(totalSupply().add(amount) <= MAX_SUPPLY, "Purchase would exceed max supply");
        require(PRICE.mul(amount) == msg.value, "Value sent is not correct");

        purchases[msg.sender] = purchases[msg.sender] + amount;

        for(uint i = 0; i < amount; i++) {
            uint mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                _safeMint(msg.sender, mintIndex);
            }
        }
    }
}