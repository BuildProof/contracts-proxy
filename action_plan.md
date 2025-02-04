# Action Plan: Making Attestor Contract Permissionless

## Current State

The Attestor contract currently uses:

- Ownable2StepUpgradeable for owner-only functions
- A whitelist system for attestors
- Restricted access to all main functionality via `onlyWhitelistedAttestor` modifier
- Acts as an intermediary where the Attestor's address is used for deposits/redemptions, not the caller's address

## Required Changes

### 1. Remove Access Control

- Remove Ownable2StepUpgradeable inheritance
- Remove whitelistedAttestors mapping
- Remove onlyWhitelistedAttestor modifier
- Remove WhitelistedAttestorSet event

### 2. Remove Admin Functions

- Remove setEthMultiVault function (make it immutable after initialization)
- Remove whitelistAttestor function
- Remove batchWhitelistAttestors function

### 3. Modify Initialization

- Simplify init function to only set ethMultiVault
- Remove admin parameter from init
- Remove whitelist setting in init

### 4. Update Proxy Behavior

- Modify all functions to use msg.sender instead of the Attestor contract as the effective caller
- For deposit functions: use msg.sender as the receiver instead of passing a receiver parameter
- For redeem functions: ensure msg.sender is the one receiving the assets
- Update maxRedeem checks to verify msg.sender's balance instead of Attestor's balance

### 5. Update Documentation

- Update contract description to reflect permissionless nature and proxy behavior
- Remove whitelist-related comments
- Update function documentation to remove attestor references
- Add documentation about proxy behavior and direct user interaction

## Security Considerations

1. Ensure ethMultiVault address cannot be changed after initialization
2. Verify all value checks remain in place for ETH transfers
3. Maintain array length validation checks
4. Keep redeemability checks for share redemptions
5. Ensure proper forwarding of msg.value in proxy calls
6. Verify no funds can get stuck in the Attestor contract

## Testing Requirements

1. Verify any address can call all functions
2. Ensure initialization can only happen once
3. Test ETH value requirements still work
4. Verify batch operations work with any caller
5. Verify deposits are credited to actual callers
6. Verify redemptions send assets to actual callers
7. Test that maxRedeem checks work with actual user balances

## Migration Considerations

If deploying to replace an existing Attestor:

1. Users should be notified of the change
2. Previous whitelisted attestors should be informed
3. Consider a timelock or grace period before switching
4. Ensure users understand they will now interact directly with vaults through the proxy

## Benefits

- Increased decentralization
- Reduced administrative overhead
- Wider accessibility for users
- Simplified codebase
- Direct user ownership of vault positions
- Transparent proxy behavior
- No intermediary custody of assets or positions

## Architecture Changes

Before:
