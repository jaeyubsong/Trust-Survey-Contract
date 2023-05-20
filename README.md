Contract id: 0x64F9505Ecf8e701698Bfdc80787b228c35B8Da6D
https://baobab.scope.klaytn.com/account/0x64F9505Ecf8e701698Bfdc80787b228c35B8Da6D?tabId=internalTx
에서도 확인 가능


`function registerSurvey(string memory surveyId, string memory questionHash, uint reward, uint maxRespondent)`
- 새로운 설문을 등록시키기 위해 사용하는 함수. 
- 함수 호출 시 maxRespondent * rewzard 보다 같거나 많은 양의 Klay를 보내야 함.
- surveyId: 서버에서 사용하는 survey Id
- questionHash: 질문들을 해시화시킨 값 (질문 위변조 방지)
- reward: 1인당 받게 될 보상 (단위: Klay)
- maxRespondent: 받게될 최대 응답 수


`function participateSurvey(string memory surveyId, string memory responseHash)`
- 설문 참여를 위해 사용하는 함수
- surveyId를 가진 설문지가 존재하여아 하고, 이미 본인 지갑 id로 참여하고 있으면 안됨.
- participateSurvey 호출 후 maxRespondent 수까지 도달하면 자동으로 closeSurvey 호출
- surveyId: 서버에서 사용하는 survey Id
- responseHash: response를 해시화시킨 값 (답변 위변조 방지)


`function closeSurvey(string memory surveyId)`
- 참여자들에게 reward 만큼의 보상을 나누어준 후 보상이 남아있다면 survey를 만든 wallet에게 돌려줌
- closeSurvey는 survey를 만든 사람이 불러야 함
- surveyId: 서버에서 사용하는 survey id

---

REMIX DEFAULT WORKSPACE

Remix default workspace is present when:
i. Remix loads for the very first time 
ii. A new workspace is created with 'Default' template
iii. There are no files existing in the File Explorer

This workspace contains 3 directories:

1. 'contracts': Holds three contracts with increasing levels of complexity.
2. 'scripts': Contains four typescript files to deploy a contract. It is explained below.
3. 'tests': Contains one Solidity test file for 'Ballot' contract & one JS test file for 'Storage' contract.

SCRIPTS

The 'scripts' folder has four typescript files which help to deploy the 'Storage' contract using 'web3.js' and 'ethers.js' libraries.

For the deployment of any other contract, just update the contract's name from 'Storage' to the desired contract and provide constructor arguments accordingly 
in the file `deploy_with_ethers.ts` or  `deploy_with_web3.ts`

In the 'tests' folder there is a script containing Mocha-Chai unit tests for 'Storage' contract.

To run a script, right click on file name in the file explorer and click 'Run'. Remember, Solidity file must already be compiled.
Output from script will appear in remix terminal.

Please note, require/import is supported in a limited manner for Remix supported modules.
For now, modules supported by Remix are ethers, web3, swarmgw, chai, multihashes, remix and hardhat only for hardhat.ethers object/plugin.
For unsupported modules, an error like this will be thrown: '<module_name> module require is not supported by Remix IDE' will be shown.
