// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./IStudentsRegistry.sol";
import "./ReplyCoin.sol";

contract TunaToken is ERC721 {
    
    IStudentsRegistry studentsRegistry;
    ReplyCoin replyCoin;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => uint256) tokenValues;

    // Transfer event already present in ERC721
    event NewToken(uint256 tokenId, uint256 tokenValue);

    constructor(
        IStudentsRegistry _studentsRegistry, ReplyCoin _replyCoin
    ) ERC721("TunaToken", "TUNA") {
        studentsRegistry = _studentsRegistry;
        replyCoin = _replyCoin;
    }

    function valueOf(uint256 tokenId) public view returns (uint256) {
        // Ensure that the token is assigned to an address, raise an exception if not
        ownerOf(tokenId);
        return tokenValues[tokenId];
    }

    function createNewToken(uint256 tokenValue) public returns (uint256) {
        require(
            studentsRegistry.isStudent(msg.sender),
            "Only students may create new tokens"
        );

        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        _safeMint(msg.sender, tokenId);
        tokenValues[tokenId] = tokenValue;

        emit NewToken(tokenId, tokenValue);
        return tokenId;
    }
    
    // By overriding _transfer, we include the ReplyCoin <-> TunaToken
    // exchange in all the ERC721 transfer functions
    function _transfer(
        address sender, address recipient, uint256 tokenId
    ) internal virtual override {
        super._transfer(sender, recipient, tokenId);
        replyCoin.transferFrom(recipient, sender, tokenValues[tokenId]);
    }

}
