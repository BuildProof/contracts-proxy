// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.21;

/// @title  Errors Library
/// @author 0xIntuition
/// @notice Library containing all custom errors detailing cases where the Attestor and AttestorFactory contracts may revert.
library Errors {
    ///////// ATTESTOR ERRORS ////////////////////////////////////////////////////////////////////

    error Attestor_DeployAttestorFailed();
    error Attestor_EmptyAttestorsArray();
    error Attestor_InsufficientValue();
    error Attestor_InvalidEthMultiVaultAddress();
    error Attestor_NotAWhitelistedAttestor();
    error Attestor_SharesCannotBeRedeeemed();
    error Attestor_WrongArrayLengths();
}
