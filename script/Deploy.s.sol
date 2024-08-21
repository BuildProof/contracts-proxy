// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {
    TransparentUpgradeableProxy,
    ITransparentUpgradeableProxy
} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
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

        // deploy attestorBeacon pointing to the Attestor implementation contract
        attestorBeacon = new UpgradeableBeacon(address(attestor), admin);
        console.logString("deployed UpgradeableBeacon.");

        bytes memory initData = abi.encodeWithSelector(
            AttestorFactory.init.selector, admin, IEthMultiVault(ethMultiVault), address(attestorBeacon)
        );

        // deploy AttestorFactory implementation contract
        attestorFactory = new AttestorFactory();
        console.logString("deployed AttestorFactory.");

        // deploy TransparentUpgradeableProxy for AttestorFactory
        attestorFactoryProxy = new TransparentUpgradeableProxy(
            address(attestorFactory), // logic contract address
            admin, // initial owner of the ProxyAdmin instance tied to the proxy
            initData // data to pass to the logic contract's initializer function
        );
        console.logString("deployed TransparentUpgradeableProxy for AttestorFactory.");

        // stop sending tx's
        vm.stopBroadcast();

        console.log("All contracts deployed successfully:");
        console.log("Attestor implementation address:", address(attestor));
        console.log("attestorBeacon address:", address(attestorBeacon));
        console.log("AttestorFactory implementation address:", address(attestorFactory));
        console.log("AttestorFactory proxy address:", address(attestorFactoryProxy));
    }
}
