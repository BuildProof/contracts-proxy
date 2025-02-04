// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.21;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Errors} from "src/libraries/Errors.sol";
import {IEthMultiVault} from "src/interfaces/IEthMultiVault.sol";

/**
 * @title  Attestor
 * @author 0xIntuition
 * @notice A proxy contract for the Intuition protocol that allows any user to interact directly with the EthMultiVault.
 *         The contract acts as a pure proxy, where all operations are performed on behalf of the caller (msg.sender).
 */
contract Attestor is Initializable {
    /// @notice The EthMultiVault contract address - immutable after initialization
    IEthMultiVault public ethMultiVault;

    /// @notice Event emitted when the EthMultiVault contract address is set during initialization
    /// @param ethMultiVault EthMultiVault contract address
    event EthMultiVaultSet(IEthMultiVault ethMultiVault);

    /// @notice Initializes the Attestor contract with the EthMultiVault address
    /// @param _ethMultiVault EthMultiVault contract
    function init(IEthMultiVault _ethMultiVault) external initializer {
        if (address(_ethMultiVault) == address(0)) {
            revert Errors.Attestor_InvalidEthMultiVaultAddress();
        }
        ethMultiVault = _ethMultiVault;
        emit EthMultiVaultSet(_ethMultiVault);
    }

    /// @dev Creates multiple atom vaults in batch, using msg.sender as the owner
    function batchCreateAtom(
        bytes[] calldata atomUris
    ) external payable returns (uint256[] memory) {
        uint256[] memory ids = ethMultiVault.batchCreateAtom{value: msg.value}(
            atomUris
        );
        return ids;
    }

    /// @notice Creates multiple atom vaults with different values in a single transaction
    /// @param atomUris Array of atom URIs
    /// @param values Array of asset values to create the vaults
    /// @return ids Array of atom vault IDs
    function batchCreateAtomDifferentValues(
        bytes[] calldata atomUris,
        uint256[] calldata values
    ) external payable returns (uint256[] memory) {
        if (atomUris.length != values.length) {
            revert Errors.Attestor_WrongArrayLengths();
        }

        uint256 sum = _getSum(values);
        if (msg.value < sum) {
            revert Errors.Attestor_InsufficientValue();
        }

        uint256[] memory ids = new uint256[](atomUris.length);
        for (uint256 i = 0; i < atomUris.length; i++) {
            ids[i] = ethMultiVault.createAtom{value: values[i]}(atomUris[i]);
        }

        return ids;
    }

    /// @dev Creates multiple triple vaults in batch, using msg.sender as the owner
    function batchCreateTriple(
        uint256[] calldata subjectIds,
        uint256[] calldata predicateIds,
        uint256[] calldata objectIds
    ) external payable returns (uint256[] memory) {
        uint256[] memory ids = ethMultiVault.batchCreateTriple{
            value: msg.value
        }(subjectIds, predicateIds, objectIds);
        return ids;
    }

    /// @notice Creates multiple triple vaults with different values in a single transaction
    function batchCreateTripleDifferentValues(
        uint256[] calldata subjectIds,
        uint256[] calldata predicateIds,
        uint256[] calldata objectIds,
        uint256[] calldata values
    ) external payable returns (uint256[] memory) {
        if (
            subjectIds.length != predicateIds.length ||
            predicateIds.length != objectIds.length
        ) {
            revert Errors.Attestor_WrongArrayLengths();
        }

        uint256 length = subjectIds.length;
        if (length != values.length) {
            revert Errors.Attestor_WrongArrayLengths();
        }

        uint256 sum = _getSum(values);
        if (msg.value < sum) {
            revert Errors.Attestor_InsufficientValue();
        }

        uint256[] memory ids = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            ids[i] = ethMultiVault.createTriple{value: values[i]}(
                subjectIds[i],
                predicateIds[i],
                objectIds[i]
            );
        }

        return ids;
    }

    /// @notice Deposits assets into multiple atom vaults in a single transaction
    function batchDepositAtom(
        uint256[] calldata ids,
        uint256[] calldata values
    ) external payable returns (uint256[] memory) {
        if (ids.length != values.length) {
            revert Errors.Attestor_WrongArrayLengths();
        }

        uint256 sum = _getSum(values);
        if (msg.value < sum) {
            revert Errors.Attestor_InsufficientValue();
        }

        uint256[] memory shares = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            shares[i] = ethMultiVault.depositAtom{value: values[i]}(
                msg.sender,
                ids[i]
            );
        }

        return shares;
    }

    /// @notice Deposits assets into multiple triple vaults in a single transaction
    function batchDepositTriple(
        uint256[] calldata ids,
        uint256[] calldata values
    ) external payable returns (uint256[] memory) {
        if (ids.length != values.length) {
            revert Errors.Attestor_WrongArrayLengths();
        }

        uint256 sum = _getSum(values);
        if (msg.value < sum) {
            revert Errors.Attestor_InsufficientValue();
        }

        uint256[] memory shares = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            shares[i] = ethMultiVault.depositTriple{value: values[i]}(
                msg.sender,
                ids[i]
            );
        }

        return shares;
    }

    /// @notice Redeems shares from multiple atom vaults for assets in a single transaction
    function batchRedeemAtom(
        uint256[] calldata shares,
        uint256[] calldata ids
    ) external returns (uint256[] memory) {
        if (shares.length != ids.length) {
            revert Errors.Attestor_WrongArrayLengths();
        }

        if (!_checkRedeemability(shares, ids)) {
            revert Errors.Attestor_SharesCannotBeRedeeemed();
        }

        uint256[] memory assets = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            assets[i] = ethMultiVault.redeemAtom(shares[i], msg.sender, ids[i]);
        }

        return assets;
    }

    /// @notice Redeems shares from multiple triple vaults for assets in a single transaction
    function batchRedeemTriple(
        uint256[] calldata shares,
        uint256[] calldata ids
    ) external returns (uint256[] memory) {
        if (shares.length != ids.length) {
            revert Errors.Attestor_WrongArrayLengths();
        }

        if (!_checkRedeemability(shares, ids)) {
            revert Errors.Attestor_SharesCannotBeRedeeemed();
        }

        uint256[] memory assets = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            assets[i] = ethMultiVault.redeemTriple(
                shares[i],
                msg.sender,
                ids[i]
            );
        }

        return assets;
    }

    /// @dev Checks if shares can be redeemed for assets from multiple vaults
    function _checkRedeemability(
        uint256[] calldata shares,
        uint256[] calldata ids
    ) internal view returns (bool) {
        if (shares.length != ids.length) {
            revert Errors.Attestor_WrongArrayLengths();
        }

        for (uint256 i = 0; i < ids.length; i++) {
            if (ethMultiVault.maxRedeem(msg.sender, ids[i]) < shares[i]) {
                return false;
            }
        }

        return true;
    }

    /// @dev Computes the sum of an array of values
    function _getSum(
        uint256[] calldata values
    ) internal pure returns (uint256) {
        uint256 sum;
        for (uint256 i = 0; i < values.length; i++) {
            sum += values[i];
        }
        return sum;
    }
}
