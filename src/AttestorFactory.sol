// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.21;

import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";

import {Attestor} from "src/Attestor.sol";
import {Errors} from "src/libraries/Errors.sol";
import {IEthMultiVault} from "src/interfaces/IEthMultiVault.sol";

/**
 * @title  AttestorFactory
 * @author 0xIntuition
 * @notice A utility contract of the Intuition protocol. It allows for the deployment of Attestor contracts using the BeaconProxy pattern.
 */
contract AttestorFactory is Initializable, Ownable2StepUpgradeable {
    /// @notice The EthMultiVault contract address
    IEthMultiVault public ethMultiVault;

    /// @notice The address of the UpgradeableBeacon contract, which points to the implementation of the Attestor contract
    address public attestorBeacon;

    /// @notice The count of deployed Attestor contracts
    uint256 public count;

    /// @notice Event emitted when an Attestor contract is deployed
    ///
    /// @param attestor The address of the deployed Attestor contract
    /// @param admin The address of the admin
    event AttestorDeployed(address indexed attestor, address indexed admin);

    /// @notice Event emitted when the EthMultiVault contract address is set
    /// @param ethMultiVault EthMultiVault contract address
    event EthMultiVaultSet(IEthMultiVault ethMultiVault);

    /// @notice Initializes the AttestorFactory contract
    ///
    /// @param admin The address of the admin
    /// @param _ethMultiVault EthMultiVault contract
    function init(address admin, IEthMultiVault _ethMultiVault, address _attestorBeacon) external initializer {
        __Ownable_init(admin);
        ethMultiVault = _ethMultiVault;
        attestorBeacon = _attestorBeacon;
    }

    /// @notice Deploys a new Attestor contract
    /// @param admin The address of the admin of the new Attestor contract
    /// @return attestorAddress The address of the deployed Attestor contract
    function deployAttestor(address admin) external returns (address) {
        // compute salt for create2
        bytes32 salt = bytes32(count);

        // get contract deployment data
        bytes memory data = _getDeploymentData(admin);

        address attestorAddress;

        // deploy attestor contract with create2:
        // value sent in wei,
        // memory offset of `code` (after first 32 bytes where the length is),
        // length of `code` (first 32 bytes of code),
        // salt for create2
        assembly {
            attestorAddress := create2(0, add(data, 0x20), mload(data), salt)
        }

        if (attestorAddress == address(0)) {
            revert Errors.Attestor_DeployAttestorFailed();
        }

        ++count;

        emit AttestorDeployed(attestorAddress, admin);

        return attestorAddress;
    }

    /// @notice Computes the address of the Attestor contract that would be deployed using deployAttestor function
    ///         with the given admin address and the `count` value
    ///
    /// @param _count The count value to be used in the computation as the salt for create2
    /// @param admin The address of the admin of the new Attestor contract
    ///
    /// @return address The address of the Attestor contract that would be deployed
    function computeAttestorAddress(uint256 _count, address admin) public view returns (address) {
        // compute salt for create2
        bytes32 salt = bytes32(_count);

        // get contract deployment data
        bytes memory data = _getDeploymentData(admin);

        // compute the raw contract address
        bytes32 rawAddress = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(data)));

        return address(bytes20(rawAddress << 96));
    }

    /// @dev returns the deployment data for the Attestor contract
    /// @param admin The address of the admin of the new Attestor contract
    /// @return bytes memory the deployment data for the Attestor contract (using BeaconProxy pattern)
    function _getDeploymentData(address admin) internal view returns (bytes memory) {
        // Address of the UpgradeableBeacon contract
        address beaconAddress = attestorBeacon;

        // BeaconProxy creation code
        bytes memory code = type(BeaconProxy).creationCode;

        // encode the init function of the Attestor contract with constructor arguments
        bytes memory initData = abi.encodeWithSelector(Attestor.init.selector, admin, ethMultiVault);

        // encode constructor arguments of the BeaconProxy contract (address beacon, bytes memory data)
        bytes memory encodedArgs = abi.encode(beaconAddress, initData);

        // concatenate the BeaconProxy creation code with the ABI-encoded constructor arguments
        return abi.encodePacked(code, encodedArgs);
    }

    /// @notice Sets the EthMultiVault contract address
    /// @param _ethMultiVault EthMultiVault contract address
    function setEthMultiVault(IEthMultiVault _ethMultiVault) external onlyOwner {
        if (address(_ethMultiVault) == address(0)) {
            revert Errors.Attestor_InvalidEthMultiVaultAddress();
        }

        ethMultiVault = _ethMultiVault;

        emit EthMultiVaultSet(_ethMultiVault);
    }
}
