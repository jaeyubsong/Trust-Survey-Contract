// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "hardhat/console.sol";

contract TrustSurvey {
    struct Response {
        address walletId;
        string responseHash;
    }
    struct Survey {
        address owner;
        string questionHash;
        string[] responseIdList;
        uint rewardPerUser;
        uint depositedReward;
        uint maxRespondent;
        bool isClosed;
    }

    // Array of surveys
    mapping(string => Survey) surveys;
    mapping(string => Response) responses;
    uint age;
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function toAsciiString(address x) private pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function char(bytes1 b) private pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function compare(string memory str1, string memory str2) private pure returns (bool) {
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }

    function getBalance() private view returns (uint) {
        return address(this).balance;
    }

    function deposit() public payable {
        require(msg.sender == owner);
    }


    function transfer(address _to, uint _value) private returns (bool) {
        require(getBalance() >= _value);
        payable(_to).transfer(_value);
        return true;
    }


    function registerSurvey(string memory surveyId, string memory questionHash, uint reward, uint maxRespondent) public payable returns (bool) {
        // Check if survey generator is giving enough
        require(msg.value >= reward * maxRespondent * 1 ether, "Error: Not enough reward");
        // require(msg.value >= reward * maxRespondent, "Error: Not enough reward");


        Survey memory s;
        s.owner = msg.sender;
        s.questionHash = questionHash;
        s.rewardPerUser = reward * 1 ether;
        // s.rewardPerUser = reward;
        s.depositedReward = msg.value;
        s.maxRespondent = maxRespondent;
        surveys[surveyId] = s;
        return true;
    }

    function participateSurvey(string memory surveyId, string memory responseHash) public returns (bool) {
        // string memory responseId = string.concat(toString(msg.sender), surveyId);
        string memory responseId = string.concat(toAsciiString(msg.sender), surveyId);
        bool responseIdExists = false;
        require(surveys[surveyId].maxRespondent > 0, "Error: surveyId does not exist");
        require(surveys[surveyId].isClosed == false, "Error: survey is already closed");
        // Check that participant already exists

        Survey memory s = surveys[surveyId];


        // Survey memory s = surveys[surveyId];
        // string[] memory newResponseIdList = new string[](s.responseIdList.length + 1);
        for (uint i = 0; i < s.responseIdList.length; i++) {
            if (compare(s.responseIdList[i], responseId)) {
                responseIdExists = true;
            }
        }
        require(responseIdExists == false, "Error: Responder already participating in survey");

        responses[responseId] = Response(msg.sender, responseHash);
        surveys[surveyId].responseIdList.push(responseId);

        // // Check if survey needs to be closed
        if (surveys[surveyId].responseIdList.length == s.maxRespondent) {
            closeSurveyInternal(surveyId);
        }

        return true;
    }

    function closeSurveyInternal(string memory surveyId) private {
        // Check if survey's owner is the caller
        Survey memory s = surveys[surveyId];
        surveys[surveyId].isClosed = true;

        // Distribute rewards
        for (uint i = 0; i < s.responseIdList.length; i++) {
            transfer(responses[s.responseIdList[i]].walletId, s.rewardPerUser);
        }

        // Return remaining reward to user
        uint remaining = s.depositedReward - s.rewardPerUser * s.responseIdList.length;
        if (remaining > 0) {
            transfer(s.owner, remaining);
        }
    }

    function closeSurvey(string memory surveyId) public {
        require(surveys[surveyId].maxRespondent > 0, "Error: surveyId does not exist");
        // Check if survey's owner is the caller
        Survey memory s = surveys[surveyId];
        require(msg.sender == s.owner, "Error: sender id not matching survey owner id");
        surveys[surveyId].isClosed = true;

        // Distribute rewards
        for (uint i = 0; i < s.responseIdList.length; i++) {
            transfer(responses[s.responseIdList[i]].walletId, s.rewardPerUser);
        }

        // Return remaining reward to user
        uint remaining = s.depositedReward - s.rewardPerUser * s.responseIdList.length;
        if (remaining > 0) {
            transfer(msg.sender, remaining);
        }
    }


    // Returns questionHash, [response1Hash, response2Hash,...]
    function getSurveyHash(string memory surveyId) public view returns (string memory, string[] memory) {
        require(surveys[surveyId].maxRespondent > 0, "Error: surveyId does not exist");
        // Check if survey's owner is the caller
        Survey memory s = surveys[surveyId];
        require(msg.sender == s.owner, "Error: sender id not matching survey owner id");


        string[] memory responseHashList = new string[](s.responseIdList.length);
        for (uint i = 0; i < s.responseIdList.length; i++) {
            responseHashList[i] = responses[s.responseIdList[i]].responseHash;
        }
        return (s.questionHash, responseHashList);
    }

    // Survey 종료 조건
    // 1) Close 직접 누르기
    // 2) addReponse 시점에 인원이 다 찼을때

    // Register
    // Client->Server
    // Client->Chain 

    // Participate
    // Client->Server
    // Client->Chain (성공 시 만약 max 인원수가 다 찼으면 close 된걸로 간주)


}