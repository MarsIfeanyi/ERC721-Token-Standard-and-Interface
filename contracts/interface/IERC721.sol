pragma solidity ^0.4.20;


/**
 * Hint: Interface gives you the function prototype which helps you to easily interact with any contract that implements the interface. 
 * The Interface(Function Prototype), specifies the function's name, the types of its parameters, and the types of its return values.
 * Interface is similar to ABI. For You to interact with any contract you need the ABI and the contract address.abi
 */

interface ERC721  /* is ERC165 */  {
  
    /**
     * @dev This emits when ownership of any NFT changes by any mechanism.
     * This event emits when NFTs are created (`from` == 0) and destroyed 
     * (`to` == 0). Exception: during contract creation, any number of NFTs
     * may be created and assigned without emitting Transfer. At the time of 
     * any transfer, the approved address for that NFT (if any) is reset to none.
     */
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

   

    /**
     *  @dev This emits when the approved address for an NFT is changed or 
     * reaffirmed. The zero address indicates there is no approved address.
     *  When a Transfer event emits, this also indicates that the approved address for that NFT (if any) is reset to none.
     */
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

  
    /**
     * @dev This emits when an operator is enabled or disabled for an owner.
     * The operator can manage all NFTs of the owner.
     */
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

 
    /**
     * @notice Count all NFTs assigned to an owner. 
     * @dev NFTs assigned to the zero address are considered invalid, and this function throws for queries about the zero address.
     * @param _owner An address for whom to query the balance.
     * @return The number of NFTs owned by `_owner`, possibly zero.
     */
    function balanceOf(address _owner) external view returns (uint256); // Hint: mapping (address => uint256) balance;


/**
 * @notice Find the owner of an NFT
 * @dev NFTs assigned to zero address are considered invalid, and queries
 *  about them do throw.
 * @param _tokenId The identifier for an NFT
 * @return The address of the owner of the NFT
 */

    function ownerOf(uint256 _tokenId) external view returns (address); // Hint: mapping (tokenId => address) owner;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    
    
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes data
    ) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external; // Hint: This is a very dangerous function, mind how you use it.

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view returns (bool);
}


interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}


// Hint: A wallet/broker/auction application MUST implement the wallet interface if it will accept safe transfers.Whenever you call safeTransferFrom, it carries out a check the EOA or Smart contract can receive NFT. By default all EOA can receieve NFTs, thus you need to implement this in your smart contract if you want you smart contract to receive NFTs.
interface ERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing

    /**
     * Hints: 
     * Function Protoype =  onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data)
     * Funtion Signature (32bytes) =  keccak256( Function Protoype)
     * Function Selector = bytes4(Funtion Signature)
     * 
     * VIP: The function selector is the first four bytes of the Keccak-256 hash of the function's signature. When a function is called in a contract, the Ethereum Virtual Machine (EVM) uses this function selector to determine which function to executed
     */
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4); 


interface ERC721Metadata /* is ERC721 */ {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string _name);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string _symbol);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721 Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string);
}



// Hint: The enumeration extension is OPTIONAL for ERC-721 smart contracts (see “caveats”, below). This allows your contract to publish its FULL LIST of NFTs and make them discoverable.

// Hint: enumerate, means to List details of something

/// @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x780e9d63.
interface ERC721Enumerable /* is ERC721 */ {
    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256);

    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`
    /// @param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256); 

    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

