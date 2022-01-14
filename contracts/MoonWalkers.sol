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
    uint public maxPerUser = 3;
    uint256 public MAX_SUPPLY = 3500;
    bool public saleIsActive = false;

    // mapping of address to amount
    mapping (address => uint256) public purchases;

    constructor(string memory name, string memory symbol, string memory _defaultURI, uint256 _royaltiesFees, address _royaltiesAddress)
        ERC721(name, symbol)
        ERC2981(_royaltiesFees, _royaltiesAddress)
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
        require(0 == msg.value, "That's a free mint");

        purchases[msg.sender] = purchases[msg.sender] + amount;

        for(uint i = 0; i < amount; i++) {
            uint mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                _safeMint(msg.sender, mintIndex);
            }
        }
    }
}
