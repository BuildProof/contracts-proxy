// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.21;

/// @title  Errors Library
/// @author 0xIntuition
/// @notice Library containing all custom errors detailing cases where the Attestoor and AttestoorFactory contracts may revert.
library Errors {
    ///////// ATTESTOOR ERRORS ////////////////////////////////////////////////////////////////////

    error Attestoor_DeployAttestoorFailed();
    error Attestoor_EmptyAttestorsArray();
    error Attestoor_InsufficientValue();
    error Attestoor_InvalidEthMultiVaultAddress();
    error Attestoor_NotAWhitelistedAttestor();
    error Attestoor_SharesCannotBeRedeeemed();
    error Attestoor_WrongArrayLengths();
}
