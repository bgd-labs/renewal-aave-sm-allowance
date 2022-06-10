// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {BaseTest} from "./base/BaseTest.sol";
import {AaveGovHelpers, IAaveGov} from "./utils/AaveGovHelpers.sol";
import {AllowanceRenewalSMPayload} from "../AllowanceRenewalSMPayload.sol";
import {IAaveEcosystemReserveController} from "../interfaces/IAaveEcosystemReserveController.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IStakedAave} from "../interfaces/IStakedAave.sol";
import {console} from "./utils/console.sol";

contract ValidationRenewalAllowanceSM is BaseTest {
    address internal constant AAVE_WHALE =
        0x25F2226B597E8F9514B3F68F00f494cF4f286491;

    IERC20 public constant AAVE =
        IERC20(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);

    address public constant STKAAVE =
        0x4da27a545c0c5B758a6BA100e3a049001de870f5;
    address public constant STKABPT =
        0xa1116930326D21fB917d5A27F1E9943A9595fb47;
    IAaveEcosystemReserveController
        public constant ECOSYSTEM_RESERVE_CONTROLLER =
        IAaveEcosystemReserveController(
            0x3d569673dAa0575c936c7c67c4E6AedA69CC630C
        );
    address public constant ECOSYSTEM_RESERVE =
        0x25F2226B597E8F9514B3F68F00f494cF4f286491;

    function setUp() public {}

    /// @dev Deploys a payload and uses it on a new proposal
    function testProposalPrePayload() public {
        _testProposal(address(new AllowanceRenewalSMPayload()));
    }

    function _testProposal(address payload) internal {
        // Address not able to claim on stkABPT, pre-proposal (block 14933680)
        address user = 0x36C4Bd54D54DD898C242F5F634f5D0CEf3bE2A8A;

        vm.startPrank(user);

        // We check the claimRewards() fails pre-proposal, as expected
        try IStakedAave(STKABPT).claimRewards(user, type(uint256).max) {
            revert("_testProposal() : CLAMING_PREPROPOSAL_NOT_REVERTING");
        } catch Error(string memory revertReason) {
            require(
                keccak256(bytes(revertReason)) ==
                    keccak256(bytes("SafeERC20: low-level call failed")),
                "_testProposal() : INVALID_REVERT_REASON"
            );
            vm.stopPrank();
        }

        address[] memory targets = new address[](1);
        targets[0] = payload;
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        string[] memory signatures = new string[](1);
        signatures[0] = "execute()";
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "";
        bool[] memory withDelegatecalls = new bool[](1);
        withDelegatecalls[0] = true;

        uint256 proposalId = AaveGovHelpers._createProposal(
            vm,
            AAVE_WHALE,
            IAaveGov.SPropCreateParams({
                executor: AaveGovHelpers.SHORT_EXECUTOR,
                targets: targets,
                values: values,
                signatures: signatures,
                calldatas: calldatas,
                withDelegatecalls: withDelegatecalls,
                ipfsHash: bytes32(0)
            })
        );

        AaveGovHelpers._passVote(vm, AAVE_WHALE, proposalId);

        require(
            AAVE.allowance(ECOSYSTEM_RESERVE, STKAAVE) == 401_500 ether,
            "INVALID_AAVE_ALLOWANCE_ON_STKAAVE"
        );
        require(
            AAVE.allowance(ECOSYSTEM_RESERVE, STKABPT) == 401_500 ether,
            "INVALID_AAVE_ALLOWANCE_ON_STKABPT"
        );

        // We check the user is able to claim post-proposal
        vm.startPrank(user);
        IStakedAave(STKABPT).claimRewards(user, type(uint256).max);
        vm.stopPrank();
    }
}
