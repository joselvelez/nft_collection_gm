// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

/// @title An NFT Collection of 'gm' setups
/// @author josevelez.eth
/// @notice Find or mint an NFT that best represents your typical 'morning setup

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import { Base64 } from "./libraries/Base64.sol";

contract GoodMorning is ERC721URIStorage {
    /// @notice 
    using Counters for Counters.Counter;

    /// @dev Contract variables
    Counters.Counter private _tokenIds;

    /// @dev mapping of each string combo by string array index, e.g. '1111', '1112'
    mapping(uint => bool) public stringCombos;

    string[] private city = [
        "Dallas",
        "Sao Paulo",
        "New York",
        "San Juan",
        "Tokyo",
        "Lisbon",
        "Paris",
        "Berlin",
        "Madrid",
        "Barcelona",
        "Frankfurt",
        "Florianopolis",
        "San Francisco",
        "Miami",
        "Milan",
        "Rome",
        "Tallin",
        "Prague",
        "London"
    ];

    string[] private breakfast = [
        "bacon and eggs",
        "avocado toast",
        "smoothie",
        "fruit",
        "oatmeal",
        "yogurt",
        "eggs benedict"
    ];

    string[] private drink = [
        "coffee",
        "tea",
        "water",
        "mate",
        "scotch",
        "hot chocolate",
        "carrot-orange juice"
    ];

    string[] private doing = [
        "checking Twitter",
        "claiming candies on CoinGecko",
        "$git push origin main",
        "$npx hardhat run scripts/deploy.ts",
        "catching up in the Discord",
        "uploading new '...oooooor' meme",
        "reporting another discord spammer",
        "$npx create-react-app --typescript .",
        "$npx create-react-app .",
        "$npx create-next-app --typescript .",
        "$npx create-next-app .",
        "$git add .",
        "$git commit -m 'initial commit'",
        "$mkdir coolNewProject"
    ];

    constructor() ERC721 ("gm kit", "GMKIT") {
        console.log("Good morning fam! What does your typical 'gm' setup look like?");
        /// @dev increment _tokenIds to begin at 1 instead of 0
        _tokenIds.increment();
    }

    function abiEncodeInput(uint tokenId) public view returns (bytes memory) {
        /// @param tokenId the current value for _tokenIds
        /// @return bytes array of the abi.Encoded sender address, current token Id, & block timestamp
        return abi.encode(msg.sender, Strings.toString(tokenId), Strings.toString(block.timestamp));
    }

    function kHash(bytes memory kHashInput) public pure returns (uint) {
        /// @param kHashInput return value from abiEncodeInput function
        /// @return uint value converted from the keccak256 hash of the kHashInput
        return uint(keccak256(kHashInput));
    }

    function random(uint arrayLength, uint tokenId) public view returns (uint) {
        /// @param arrayLength lenth of string array
        /// @return uint value between 0 and array length
        bytes memory abiEncodeOutput = abiEncodeInput(tokenId);
        uint kHashOutput = kHash(abiEncodeOutput);
        return kHashOutput % arrayLength;
    }

    /// @dev use the randomly generated number to pluck a string from the selected arrays

    function getCity(uint tokenId) private view returns (string memory) {
        uint cityArrayLength = city.length;
        return city[random(cityArrayLength, tokenId)];
    }

    function getBreakfast(uint tokenId) private view returns (string memory) {
        uint breakfastArrayLength = breakfast.length;
        return breakfast[random(breakfastArrayLength, tokenId)];
    }

    function getDrink(uint tokenId) private view returns (string memory) {
        uint drinkArrayLength = drink.length;
        return drink[random(drinkArrayLength, tokenId)];
    }

    function getDoing(uint tokenId) private view returns (string memory) {
        uint doingArrayLength = doing.length;
        return doing[random(doingArrayLength, tokenId)];
    }

    function generateSVG(uint tokenId) private view returns (string[5] memory) {
        string[13] memory parts;

        parts[0] = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 16px; }</style><rect width='100%' height='100%' fill='black' />";
        parts[1] = "<text x='2%' y='25%' class='base' dominant-baseline='middle' text-anchor='start'>";
        parts[2] = getCity(tokenId);
        parts[3] = "</text>";
        parts[4] = "<text x='2%' y='33%' class='base' dominant-baseline='middle' text-anchor='start'>";
        parts[5] = getBreakfast(tokenId);
        parts[6] = "</text>";
        parts[7] = "<text x='2%' y='41%' class='base' dominant-baseline='middle' text-anchor='start'>";
        parts[8] = getDrink(tokenId);
        parts[9] = "</text>";
        parts[10] = "<text x='2%' y='49%' class='base' dominant-baseline='middle' text-anchor='start'>";
        parts[11] = getDoing(tokenId);
        parts[12] = "</text></svg>";

        /// @dev split array up to prevent 'stack too deep' compile erros
        string memory firstHalf = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6]));
        string memory secondHalf = string(abi.encodePacked(parts[7], parts[8], parts[9], parts[10], parts[11], parts[12]));
        string memory finalSVG = string(abi.encodePacked(firstHalf, secondHalf));
        return [finalSVG, string(abi.encodePacked(parts[2])), string(abi.encodePacked(parts[5])), string(abi.encodePacked(parts[8])), string(abi.encodePacked(parts[11]))];
    }

    function generateJSON(uint tokenId) private view returns (string memory) {
        return Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":', '"gmKit #', Strings.toString(tokenId), '",',
                        '"description": "A collection of kits to identify the typical morning for a web3 builder. Find or mint an NFT that best represents your typical morning setup",',
                        '"image": "data:image/svg+xml;base64,', Base64.encode(bytes(generateSVG(tokenId)[0])), '",',
                        '"attributes": [{"trait_type":"currently in ","value":"', generateSVG(tokenId)[1], '"},',
                        '{"trait_type":"having ","value":"', generateSVG(tokenId)[2], '"},',
                        '{"trait_type":"drinking  ","value":"', generateSVG(tokenId)[3], '"},',
                        '{"trait_type":"doing  ","value":"', generateSVG(tokenId)[4], '"}]'
                        '}'
                    )
                )
            )
        );
    }

    function mintGMKit() public {
        uint _newTokenId = _tokenIds.current();

        string memory json = generateJSON(_newTokenId);
        string memory finalTokenURI = string(abi.encodePacked("data:application/json;base64,", json));

        console.log("\n-------------------------------");
        console.log(finalTokenURI);
        console.log("-------------------------------\n");

        _safeMint(msg.sender, _newTokenId);

        _setTokenURI(_newTokenId, finalTokenURI);
        console.log("A new 'gm' kit with ID %s has been minted by %s", _newTokenId, msg.sender);

        _tokenIds.increment();
    }
}