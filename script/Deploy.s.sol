// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

import {Attestor} from "src/Attestor.sol";
import {AttestorFactory} from "src/AttestorFactory.sol";
import {IEthMultiVault} from "src/interfaces/IEthMultiVault.sol";

contract Deploy is Script {
    address deployer;

    address admin = 0xEcAc3Da134C2e5f492B702546c8aaeD2793965BB; // Testnet multisig Safe address
    address ethMultiVault = 0x78f576A734dEEFFd0C3550E6576fFf437933D9D5; // EthMultiVault proxy address on testnet

    TransparentUpgradeableProxy attestorFactoryProxy;
    UpgradeableBeacon attestorBeacon;

    AttestorFactory attestorFactory;
    Attestor attestor;

    function run() external {
        // Begin sending tx's to network
        vm.startBroadcast();

        // deploy Attestor implementation contract
        attestor = new Attestor();
        console.logString("deployed Attestor.");

        // stop sending tx's
        vm.stopBroadcast();

        console.log("Attestor implementation address:", address(attestor));
    }
}
