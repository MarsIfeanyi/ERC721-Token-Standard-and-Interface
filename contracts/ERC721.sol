// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract ERC721 {
    // A for B Pattern
    using Address for address;
    using Strings for uint256; // This allows us to easily call all the functions defined in the String libarary on any Uint256.VIP: Since you have defined the library for uint256, you can't call it for uint8, unit16, uint32 and the rest.

    string private tokenName;
    string private tokenSymbol;

    // mapping(uint256 tokenID => address owner) private tokenIDToAddress_Owners;
    mapping(uint256 => address) private tokenIDToAddress_Owners; // ownerOf()

    // mapping(address owner => uint256 tokenCount) private addressToTokenCount_Balances;
    mapping(address => uint256) private addressToTokenCount_Balances; // balanceOf()

    //  mapping(uint256 tokenID => address approvedUser) private tokenIDToAddress_TokenApprovals;
    mapping(uint256 => address) private tokenIDToAddress_TokenApprovals;

    //  mapping(address owner => mapping(address operator => bool isApproved)) private   ownerToOperator_OperatorApprovals;
    mapping(address => mapping(address => bool))
        private ownerToOperator_OperatorApprovals;

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool isApproved
    );

    event Transfer(address indexed from, address indexed to, uint256 tokenId);

    constructor(string memory _tokenName, string memory _tokenSymbol) {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
    }

    function name() external view returns (string memory) {
        return tokenName;
    } // Hint: Specified in the interface of ERC721Metadata

    function symbol() external view returns (string memory) {
        return tokenSymbol;
    } // Hint: Specified in the interface of ERC721Metadata

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "ERC721: Not a Valid Address");

        return addressToTokenCount_Balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        address owner = _ownerOf(_tokenId);
        // Hint: here we called an internal function, _ownerOf(). WHY?, REASON: we created the internal function to allow us to get the address of the owner using the tokenIDToAddress_Owners mapping and thus here we will CHECK that the address is not a zero address
        require(owner != address(0), "ERC721: Not a Valid Address");

        return owner;
    }

    function _ownerOf(uint256 tokenId) internal view returns (address) {
        return tokenIDToAddress_Owners[tokenId];
    } // Hint: This function is only accessible within the contract

    // Hint: Before you can't get the tokenURI, you check to confirm that the token has existed and for the token to exist, it MUST have been minted already.
    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        _requireMinted(_tokenId);

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, _tokenId.toString()))
                : ""; // Tenary Operation
    } // Hint: The tokenURI  is Specified in the ERC721Metadata interface

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal pure returns (string memory) {
        return "";
    }

    function _requireMinted(uint256 _tokenId) internal view {
        require(_exists(_tokenId), "ERC721: Invalid token ID");
    }

    function _exists(uint256 _tokenId) internal view virtual returns (bool) {
        return _ownerOf(_tokenId) != address(0);
    }

    function approve(address to, uint256 _tokenId) public {
        address owner = _ownerOf(_tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, _tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 _tokenId) internal virtual {
        tokenIDToAddress_TokenApprovals[_tokenId] = to;
        emit Approval(_ownerOf(_tokenId), to, _tokenId);
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view returns (bool) {
        return ownerToOperator_OperatorApprovals[owner][operator];
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        // checks that the NFT with the tokenID has been minted previously
        _requireMinted(_tokenId);

        return tokenIDToAddress_TokenApprovals[_tokenId];
    }

    function setApprovalForAll(address _operator, bool isApproved) public {
        _setApprovalForAll(msg.sender, _operator, isApproved);
    }

    function _setApprovalForAll(
        address _owner,
        address _operator,
        bool _isApproved
    ) internal virtual {
        require(_owner != _operator, "ERC721: approve to caller");
        ownerToOperator_OperatorApprovals[_owner][_operator] = _isApproved;
        emit ApprovalForAll(_owner, _operator, _isApproved);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        require(
            _isApprovedOrOwner(msg.sender, _tokenId),
            "ERC721: caller is not token owner or approved"
        );

        _transfer(_from, _to, _tokenId);
    }

    function _isApprovedOrOwner(
        address _spender,
        uint256 _tokenId
    ) internal view returns (bool) {
        address owner = _ownerOf(_tokenId);
        return (_spender == owner ||
            isApprovedForAll(owner, _spender) ||
            getApproved(_tokenId) == _spender);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        require(
            _ownerOf(_tokenId) == _from,
            "ERC721: transfer from incorrect owner"
        );
        require(_to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(_from, _to, _tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(
            _ownerOf(_tokenId) == _from,
            "ERC721: transfer from incorrect owner"
        );

        // Clear approvals from the previous owner
        delete tokenIDToAddress_TokenApprovals[_tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            addressToTokenCount_Balances[_from] -= 1;
            addressToTokenCount_Balances[_to] += 1;
        }
        tokenIDToAddress_Owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);

        _afterTokenTransfer(_from, _to, _tokenId, 1);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: caller is not token owner or approved"
        );
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            addressToTokenCount_Balances[to] += 1;
        }

        tokenIDToAddress_Owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = _ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = _ownerOf(tokenId);

        // Clear approvals
        delete tokenIDToAddress_TokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            addressToTokenCount_Balances[owner] -= 1;
        }
        delete tokenIDToAddress_Owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }
}

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
