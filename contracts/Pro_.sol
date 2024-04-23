/**
 *Submitted for verification at BscScan.com on 2024-03-22
 */

/**
 *Submitted for verification at BscScan.com on 2024-03-17
 */

// File: contracts/Registration.sol

/**
 *Submitted for verification at BscScan.com on 2024-02-21
 */

pragma solidity ^0.8.0;

contract Registration {
    address public owner;

    struct UserInfo {
        address referrer;
        address[] referrals;
        bool isRegistered;
        string userUniqueId;
    }

    mapping(address => UserInfo) public allUsers;
    mapping(string => address) public userAddressByUniqueId;
    uint256 public totalUsers;

    event UserRegistered(
        address indexed user,
        address indexed referrer,
        string uniqueId
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function GetIdFromAddress(address user)
        public
        pure
        returns (string memory)
    {
        return toString(uint160(user) % 1e10);
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        for (uint256 i = 0; i < digits; i++) {
            buffer[i] = bytes1(
                uint8(48 + ((value / 10**(digits - 1 - i)) % 10))
            );
        }

        return string(buffer);
    }

    function registerUser(string memory referrerUniqueId) external {
        address referrer = findReferrerByUniqueId(referrerUniqueId);

        UserInfo storage user = allUsers[msg.sender];
        UserInfo storage referrerInfo = allUsers[referrer];

        require(
            referrerInfo.isRegistered || referrer == owner,
            "Not registered"
        );
        require(!user.isRegistered, "Already registered");

        user.userUniqueId = GetIdFromAddress(msg.sender);
        user.referrer = referrer;
        user.isRegistered = true;
        referrerInfo.referrals.push(msg.sender);

        userAddressByUniqueId[user.userUniqueId] = msg.sender;
        totalUsers++;

        emit UserRegistered(msg.sender, referrer, user.userUniqueId);
    }

    function registerByOwner() external onlyOwner {
        UserInfo storage ownerInfo = allUsers[owner];

        require(!ownerInfo.isRegistered, "Already registered");

        ownerInfo.userUniqueId = GetIdFromAddress(owner);
        ownerInfo.referrer = owner;
        ownerInfo.isRegistered = true;
        ownerInfo.referrals.push(owner);
        userAddressByUniqueId[ownerInfo.userUniqueId] = owner;
        totalUsers++;

        emit UserRegistered(owner, address(0), ownerInfo.userUniqueId);
    }

    function findReferrerByUniqueId(string memory referrerUniqueId)
        public
        view
        returns (address)
    {
        address referrerAddress = userAddressByUniqueId[referrerUniqueId];
        require(referrerAddress != address(0), "Referrer not found");
        return referrerAddress;
    }

    function getUserInfo(address userAddress)
        external
        view
        returns (UserInfo memory)
    {
        return allUsers[userAddress];
    }

    function getDirectReferrals(address user)
        external
        view
        returns (address[] memory)
    {
        return allUsers[user].referrals;
    }

    function getTotalReferralCount(address user)
        external
        view
        returns (uint256 directReferrals, uint256 totalReferrals)
    {
        directReferrals = allUsers[user].referrals.length;
        totalReferrals = countTotalReferrals(user);
    }

    function countTotalReferrals(address user) internal view returns (uint256) {
        uint256 totalReferrals = allUsers[user].referrals.length;

        for (uint256 i = 0; i < allUsers[user].referrals.length; i++) {
            totalReferrals += countTotalReferrals(allUsers[user].referrals[i]);
        }

        return totalReferrals;
    }
}

// File: @openzeppelin/contracts/utils/StorageSlot.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot)
        internal
        pure
        returns (AddressSlot storage r)
    {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot)
        internal
        pure
        returns (BooleanSlot storage r)
    {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot)
        internal
        pure
        returns (Bytes32Slot storage r)
    {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot)
        internal
        pure
        returns (Uint256Slot storage r)
    {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot)
        internal
        pure
        returns (StringSlot storage r)
    {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store)
        internal
        pure
        returns (StringSlot storage r)
    {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot)
        internal
        pure
        returns (BytesSlot storage r)
    {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store)
        internal
        pure
        returns (BytesSlot storage r)
    {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}

// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata)
        internal
        pure
        returns (bytes memory)
    {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

// File: @openzeppelin/contracts/proxy/beacon/IBeacon.sol

// OpenZeppelin Contracts (last updated v5.0.0) (proxy/beacon/IBeacon.sol)

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {UpgradeableBeacon} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// File: @openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol

// OpenZeppelin Contracts (last updated v5.0.0) (proxy/ERC1967/ERC1967Utils.sol)

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 */
library ERC1967Utils {
    // We re-declare ERC-1967 events here because they can't be used directly from IERC1967.
    // This will be fixed in Solidity 0.8.21. At that point we should remove these events.
    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Emitted when the beacon is changed.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev The `implementation` of the proxy is invalid.
     */
    error ERC1967InvalidImplementation(address implementation);

    /**
     * @dev The `admin` of the proxy is invalid.
     */
    error ERC1967InvalidAdmin(address admin);

    /**
     * @dev The `beacon` of the proxy is invalid.
     */
    error ERC1967InvalidBeacon(address beacon);

    /**
     * @dev An upgrade function sees `msg.value > 0` that may be lost.
     */
    error ERC1967NonPayable();

    /**
     * @dev Returns the current implementation address.
     */
    function getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        if (newImplementation.code.length == 0) {
            revert ERC1967InvalidImplementation(newImplementation);
        }
        StorageSlot
            .getAddressSlot(IMPLEMENTATION_SLOT)
            .value = newImplementation;
    }

    /**
     * @dev Performs implementation upgrade with additional setup call if data is nonempty.
     * This function is payable only if the setup call is performed, otherwise `msg.value` is rejected
     * to avoid stuck value in the contract.
     *
     * Emits an {IERC1967-Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data)
        internal
    {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);

        if (data.length > 0) {
            Address.functionDelegateCall(newImplementation, data);
        } else {
            _checkNonPayable();
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Returns the current admin.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using
     * the https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        if (newAdmin == address(0)) {
            revert ERC1967InvalidAdmin(address(0));
        }
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {IERC1967-AdminChanged} event.
     */
    function changeAdmin(address newAdmin) internal {
        emit AdminChanged(getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is the keccak-256 hash of "eip1967.proxy.beacon" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant BEACON_SLOT =
        0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Returns the current beacon.
     */
    function getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        if (newBeacon.code.length == 0) {
            revert ERC1967InvalidBeacon(newBeacon);
        }

        StorageSlot.getAddressSlot(BEACON_SLOT).value = newBeacon;

        address beaconImplementation = IBeacon(newBeacon).implementation();
        if (beaconImplementation.code.length == 0) {
            revert ERC1967InvalidImplementation(beaconImplementation);
        }
    }

    /**
     * @dev Change the beacon and trigger a setup call if data is nonempty.
     * This function is payable only if the setup call is performed, otherwise `msg.value` is rejected
     * to avoid stuck value in the contract.
     *
     * Emits an {IERC1967-BeaconUpgraded} event.
     *
     * CAUTION: Invoking this function has no effect on an instance of {BeaconProxy} since v5, since
     * it uses an immutable beacon without looking at the value of the ERC-1967 beacon slot for
     * efficiency.
     */
    function upgradeBeaconToAndCall(address newBeacon, bytes memory data)
        internal
    {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);

        if (data.length > 0) {
            Address.functionDelegateCall(
                IBeacon(newBeacon).implementation(),
                data
            );
        } else {
            _checkNonPayable();
        }
    }

    /**
     * @dev Reverts if `msg.value` is not zero. It can be used to avoid `msg.value` stuck in the contract
     * if an upgrade doesn't perform an initialization call.
     */
    function _checkNonPayable() private {
        if (msg.value > 0) {
            revert ERC1967NonPayable();
        }
    }
}

// File: @openzeppelin/contracts/interfaces/draft-IERC1822.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC1822.sol)

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE =
        0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage()
        private
        pure
        returns (InitializableStorage storage $)
    {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/UUPSUpgradeable.sol)

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822Proxiable {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address private immutable __self = address(this);

    /**
     * @dev The version of the upgrade interface of the contract. If this getter is missing, both `upgradeTo(address)`
     * and `upgradeToAndCall(address,bytes)` are present, and `upgradeTo` must be used if no function should be called,
     * while `upgradeToAndCall` will invoke the `receive` function if the second argument is the empty byte string.
     * If the getter returns `"5.0.0"`, only `upgradeToAndCall(address,bytes)` is present, and the second argument must
     * be the empty byte string if no function should be called, making it impossible to invoke the `receive` function
     * during an upgrade.
     */
    string public constant UPGRADE_INTERFACE_VERSION = "5.0.0";

    /**
     * @dev The call is from an unauthorized context.
     */
    error UUPSUnauthorizedCallContext();

    /**
     * @dev The storage `slot` is unsupported as a UUID.
     */
    error UUPSUnsupportedProxiableUUID(bytes32 slot);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        _checkProxy();
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        _checkNotDelegated();
        _;
    }

    function __UUPSUpgradeable_init() internal onlyInitializing {}

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {}

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate the implementation's compatibility when performing an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID()
        external
        view
        virtual
        notDelegated
        returns (bytes32)
    {
        return ERC1967Utils.IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     *
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function upgradeToAndCall(address newImplementation, bytes memory data)
        public
        payable
        virtual
        onlyProxy
    {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data);
    }

    /**
     * @dev Reverts if the execution is not performed via delegatecall or the execution
     * context is not of a proxy with an ERC1967-compliant implementation pointing to self.
     * See {_onlyProxy}.
     */
    function _checkProxy() internal view virtual {
        if (
            address(this) == __self || // Must be called through delegatecall
            ERC1967Utils.getImplementation() != __self // Must be called through an active proxy
        ) {
            revert UUPSUnauthorizedCallContext();
        }
    }

    /**
     * @dev Reverts if the execution is performed via delegatecall.
     * See {notDelegated}.
     */
    function _checkNotDelegated() internal view virtual {
        if (address(this) != __self) {
            // Must not be called through delegatecall
            revert UUPSUnauthorizedCallContext();
        }
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev Performs an implementation upgrade with a security check for UUPS proxies, and additional setup call.
     *
     * As a security check, {proxiableUUID} is invoked in the new implementation, and the return value
     * is expected to be the implementation slot in ERC1967.
     *
     * Emits an {IERC1967-Upgraded} event.
     */
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data)
        private
    {
        try IERC1822Proxiable(newImplementation).proxiableUUID() returns (
            bytes32 slot
        ) {
            if (slot != ERC1967Utils.IMPLEMENTATION_SLOT) {
                revert UUPSUnsupportedProxiableUUID(slot);
            }
            ERC1967Utils.upgradeToAndCall(newImplementation, data);
        } catch {
            // The implementation is not UUPS
            revert ERC1967Utils.ERC1967InvalidImplementation(newImplementation);
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {}

    function __Context_init_unchained() internal onlyInitializing {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    /// @custom:storage-location erc7201:openzeppelin.storage.Ownable
    struct OwnableStorage {
        address _owner;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Ownable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant OwnableStorageLocation =
        0x9016d09d72d40fdae2fd8ceac6b6234c7706214fd39c1cd1e609a0528c199300;

    function _getOwnableStorage()
        private
        pure
        returns (OwnableStorage storage $)
    {
        assembly {
            $.slot := OwnableStorageLocation
        }
    }

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    function __Ownable_init(address initialOwner) internal onlyInitializing {
        __Ownable_init_unchained(initialOwner);
    }

    function __Ownable_init_unchained(address initialOwner)
        internal
        onlyInitializing
    {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        OwnableStorage storage $ = _getOwnableStorage();
        return $._owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        OwnableStorage storage $ = _getOwnableStorage();
        address oldOwner = $._owner;
        $._owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed
    );

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed,
        uint256 tokenId
    );

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(
        address owner,
        address spender,
        uint256 value,
        bool emitEvent
    ) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// File: contracts/Pro_Power.sol

interface RegistrationInterface {
    struct UserInfo {
        address referrer;
        address[] referrals;
        bool isRegistered;
        string userUniqueId;
    }

    function getUserInfo(address _address)
        external
        view
        returns (UserInfo memory);
}

contract Pro_Power_Matrix is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();

        packagePrices.push(0);
        packagePrices.push(5 * 10**18);
        packagePrices.push(8 * 10**18);
        packagePrices.push(14 * 10**18);
        packagePrices.push(26 * 10**18);
        packagePrices.push(50 * 10**18);
        packagePrices.push(98 * 10**18);
        packagePrices.push(194 * 10**18);
        packagePrices.push(386 * 10**18);
        packagePrices.push(770 * 10**18);
        packagePrices.push(1538 * 10**18);
        packagePrices.push(3074 * 10**18);
        packagePrices.push(6146 * 10**18);

        upline1 = payable(owner());
        upline2 = payable(owner());
        upline3 = payable(owner());
        upline4 = payable(owner());
        upline5 = payable(owner());
        structureUpline1 = payable(owner());
        structureUpline2 = payable(owner());
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    struct UserInfo {
        address referrer;
        address[] referrals;
        bool isRegistered;
        string userUniqueId;
    }

    uint256[] public packagePrices;

    mapping(address => uint256) public userPackages;
    mapping(uint256 => mapping(address => address[])) public downlines;
    mapping(uint256 => mapping(address => address[]))
        public secondLayerDownlines;
    mapping(uint256 => mapping(address => address)) public upline;

    // Declare payable addresses for upline
    address payable public upline1;
    address payable public upline2;
    address payable public upline3;
    address payable public upline4;
    address payable public upline5;
    address payable public structureUpline1;
    address payable public structureUpline2;
    address payable public uplineToUplineOFStructureUpline2;

    IERC20 public usdtToken;
    address payable public RoyaltyContract;
    RegistrationInterface public registration;

    // Constants for distribution percentages
    uint256 private constant upline1_PERCENTAGE = 40;
    uint256 private constant upline2_PERCENTAGE = 25;
    uint256 private constant upline3_PERCENTAGE = 15;
    uint256 private constant upline4_PERCENTAGE = 10;
    uint256 private constant upline5_PERCENTAGE = 10;

    event PackagePurchased(
        address indexed user,
        uint256 packageIndex,
        uint256 price,
        address upline1,
        address upline2,
        address upline3,
        address upline4,
        address upline5,
        bool royalty,
        bool recycle15,
        bool recycle16,
        address structureUpline1,
        address structureUpline2
    );

    receive() external payable {}

    function setRegistration(address _registrationAddress) external onlyOwner {
        registration = RegistrationInterface(_registrationAddress);
    }

    function setRoyalty(address _royalty) external onlyOwner {
        RoyaltyContract = payable(_royalty);
    }

    function setUSDT(address _usdtToken) external onlyOwner {
        usdtToken = IERC20(_usdtToken);
    }

    // Function to fetch user information from Registration contract
    function getUserInfo(address user) public view returns (UserInfo memory) {
        // Call the getUserInfo function from Registration contract
        RegistrationInterface registration = RegistrationInterface(
            registration
        );
        RegistrationInterface.UserInfo memory userInfoInterface = registration
            .getUserInfo(user);

        // Convert the returned UserInfo from Registration contract to local UserInfo struct
        UserInfo memory userInfo;
        userInfo.referrer = userInfoInterface.referrer;
        userInfo.referrals = userInfoInterface.referrals;
        userInfo.isRegistered = userInfoInterface.isRegistered;
        userInfo.userUniqueId = userInfoInterface.userUniqueId;

        return userInfo;
    }

    function updateAndSetDistributionAddresses(
        address currentUpline,
        uint256 packageIndex
    ) internal {
        address userUpline = currentUpline;

        uint256 qualifiedUplinesFound = 0;

        // Iterate through uplines until 5 qualified uplines are found or until the user's package index is greater than or equal to the upline's package index
        while (userUpline != address(0) && qualifiedUplinesFound < 5) {
            if (userPackages[userUpline] >= packageIndex) {
                qualifiedUplinesFound++;

                if (qualifiedUplinesFound == 1) {
                    upline1 = payable(userUpline);
                } else if (qualifiedUplinesFound == 2) {
                    upline2 = payable(userUpline);
                } else if (qualifiedUplinesFound == 3) {
                    upline3 = payable(userUpline);
                } else if (qualifiedUplinesFound == 4) {
                    upline4 = payable(userUpline);
                } else if (qualifiedUplinesFound == 5) {
                    upline5 = payable(userUpline);
                }
            }

            // Move up to the next referrer
            address referrer = getUserInfo(userUpline).referrer;
            while (
                referrer != address(0) && userPackages[referrer] < packageIndex
            ) {
                referrer = getUserInfo(referrer).referrer;
            }

            if (referrer == address(0)) {
                break; // Break the loop if no referrer with a matching or higher package index is found
            }

            userUpline = referrer;
        }

        // If upline1, upline2, upline3, upline4, or upline5 are not set, set them to the contract owner()
        if (qualifiedUplinesFound < 1) {
            upline1 = payable(owner());
        }

        if (qualifiedUplinesFound < 2) {
            upline2 = payable(owner());
        }

        if (qualifiedUplinesFound < 3) {
            upline3 = payable(owner());
        }

        if (qualifiedUplinesFound < 4) {
            upline4 = payable(owner());
        }

        if (qualifiedUplinesFound < 5) {
            upline5 = payable(owner());
        }
    }

    function purchasePackage(uint256 packageIndex) external {
        require(
            packageIndex > 0 && packageIndex < packagePrices.length,
            "Invalid package index"
        );

        uint256 currentPackageIndex = userPackages[msg.sender];

        // Check if the user has any existing package or if they are purchasing the next package in sequence
        require(
            packageIndex == currentPackageIndex + 1,
            "Purchase packages sequentially"
        );

        uint256 packagePrice = packagePrices[packageIndex];

        usdtToken.approve(address(this), packagePrice);

        // Transfer USDT from the user to the contract
        usdtToken.transferFrom(msg.sender, address(this), packagePrice);

        // Check if the user is registered
        require(getUserInfo(msg.sender).isRegistered, "Not registered");

        address referrerAddress = getUserInfo(msg.sender).referrer;
        upline[packageIndex][msg.sender] = referrerAddress;

        // Check if the referrer address is valid
        require(referrerAddress != address(0), "Referrer not found");

        updateAndSetDistributionAddresses(referrerAddress, packageIndex);

        // Distribute 2 USDT among levels 1 to 5 (deducted from the package price)
        distribute2USDT();

        uint256 remainingAmount = packagePrice - 2 * 10**18;

        // Check if the specified upline already has 4 downlines
        if (downlines[packageIndex][upline1].length < 4) {
            downlines[packageIndex][upline1].push(msg.sender);
            upline[packageIndex][msg.sender] = upline1;
            structureUpline1 = upline1;
            structureUpline2 = payable(upline[packageIndex][structureUpline1]);

            if (upline1 != owner()) {
                secondLayerDownlines[packageIndex][structureUpline2].push(
                    msg.sender
                );
            }
        } else {
            for (
                uint256 i = 0;
                i < downlines[packageIndex][upline1].length;
                i++
            ) {
                address downlineAddress = downlines[packageIndex][upline1][i];
                if (downlines[packageIndex][downlineAddress].length < 4) {
                    downlines[packageIndex][downlineAddress].push(msg.sender);
                    upline[packageIndex][msg.sender] = downlineAddress;
                    structureUpline1 = payable(downlineAddress);
                    structureUpline2 = payable(
                        upline[packageIndex][downlineAddress]
                    );

                    if (downlineAddress != owner()) {
                        secondLayerDownlines[packageIndex][structureUpline2]
                            .push(msg.sender);
                    }
                    break;
                }
            }
        }
        usdtToken.transfer(structureUpline1, remainingAmount / 2);
        distributeUSDT(structureUpline2, remainingAmount / 2, packageIndex);
        if (secondLayerDownlines[packageIndex][structureUpline2].length == 16) {
            emit PackagePurchased(
                msg.sender,
                packageIndex,
                packagePrice,
                upline1,
                upline2,
                upline3,
                upline4,
                upline5,
                false,
                false,
                true,
                structureUpline1,
                structureUpline2
            );
        }
        if (secondLayerDownlines[packageIndex][structureUpline2].length == 16) {
            recycleProcess(packageIndex, remainingAmount, structureUpline2);
        }

        // Remove the user from the downlines of their previous upline
        userPackages[msg.sender] = packageIndex;
    }

    function distribute2USDT() internal {
        uint256 usdtToDistribute = 2 * 10**18; // 2 USDT

        // Transfer USDT to levels
        usdtToken.transfer(
            upline1,
            (usdtToDistribute * upline1_PERCENTAGE) / 100
        );
        usdtToken.transfer(
            upline2,
            (usdtToDistribute * upline2_PERCENTAGE) / 100
        );
        usdtToken.transfer(
            upline3,
            (usdtToDistribute * upline3_PERCENTAGE) / 100
        );
        usdtToken.transfer(
            upline4,
            (usdtToDistribute * upline4_PERCENTAGE) / 100
        );
        usdtToken.transfer(
            upline5,
            (usdtToDistribute * upline5_PERCENTAGE) / 100
        );
    }

    function distributeUSDT(
        address StructureUpline2,
        uint256 amountToDistribute,
        uint256 packageIndex
    ) internal {
        address[] storage secondLayer = secondLayerDownlines[packageIndex][
            StructureUpline2
        ];
        uint256 i = secondLayer.length;
        uint256 packagePrice = packagePrices[packageIndex];
        // Distribute USDT according to the conditions
        if (secondLayer.length <= 15) {
            if (i == 0) {
                emit PackagePurchased(
                    msg.sender,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i >= 1 && i <= 3) {
                // Distribute to RoyaltyContract for the first 3 downlines
                usdtToken.transfer(RoyaltyContract, amountToDistribute);
                emit PackagePurchased(
                    msg.sender,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    true,
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i >= 4 && i <= 14) {
                // Distribute to upline2 for downlines 4 to 13
                usdtToken.transfer(structureUpline2, amountToDistribute);
                emit PackagePurchased(
                    msg.sender,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i == 15) {
                // Distribute to upline3 and upline4 for downlines 14
                usdtToken.transfer(address(this), amountToDistribute);

                emit PackagePurchased(
                    msg.sender,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    true,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            }
        }
    }

    function ownerBuysAllPackages() external onlyOwner {
        // Iterate through all packages and purchase them for the owner
        for (uint256 i = 1; i < packagePrices.length; i++) {
            // Update user's package index
            userPackages[owner()] = i;
            uint256 packagePrice = packagePrices[i];

            emit PackagePurchased(
                owner(),
                i,
                packagePrice,
                address(0),
                address(0),
                address(0),
                address(0),
                address(0),
                false,
                false,
                false,
                address(0),
                address(0)
            );
        }
    }

    function providePackage(uint256 packageIndex, address user)
        internal
        onlyOwner
    {
        require(
            packageIndex > 0 && packageIndex < packagePrices.length,
            "Invalid package index"
        );

        uint256 currentPackageIndex = userPackages[user];

        // Check if the user has any existing package or if they are purchasing the next package in sequence
        require(
            packageIndex == currentPackageIndex + 1,
            "Must provide packages sequentially"
        );

        // Check if the user is registered
        require(getUserInfo(user).isRegistered, "User is not registered");

        address referrerAddress = getUserInfo(user).referrer;

        // Check if the referrer address is valid
        require(referrerAddress != address(0), "Referrer not found");

        upline[packageIndex][user] = referrerAddress;

        updateAndSetDistributionAddresses(referrerAddress, packageIndex);

        // Check if the specified upline already has 4 downlines
        if (downlines[packageIndex][upline1].length < 4) {
            downlines[packageIndex][upline1].push(user);
            upline[packageIndex][user] = upline1;
            structureUpline1 = upline1;
            structureUpline2 = payable(upline[packageIndex][structureUpline1]);

            if (upline1 != owner()) {
                secondLayerDownlines[packageIndex][structureUpline2].push(user);
            }
        } else {
            for (
                uint256 i = 0;
                i < downlines[packageIndex][upline1].length;
                i++
            ) {
                address downlineAddress = downlines[packageIndex][upline1][i];
                if (downlines[packageIndex][downlineAddress].length < 4) {
                    downlines[packageIndex][downlineAddress].push(user);
                    upline[packageIndex][user] = downlineAddress;
                    structureUpline1 = payable(downlineAddress);
                    structureUpline2 = payable(
                        upline[packageIndex][downlineAddress]
                    );
                    if (structureUpline1 != owner()) {
                        secondLayerDownlines[packageIndex][structureUpline2]
                            .push(user);
                    }
                    break;
                }
            }
        }

        address[] storage secondLayer = secondLayerDownlines[packageIndex][
            structureUpline2
        ];
        uint256 i = secondLayer.length;
        uint256 packagePrice = packagePrices[packageIndex];

        if (secondLayer.length <= 16) {
            if (i == 0) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i >= 1 && i <= 3) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    true,
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i >= 4 && i <= 14) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i == 15) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    true,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i == 16) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    false,
                    true,
                    structureUpline1,
                    structureUpline2
                );
            }
        }
        if (secondLayer.length == 16) {
            recycleProvidePackage(packageIndex, structureUpline2);
        }
        userPackages[user] = packageIndex;
    }

    function providePackagesBulk(
        uint256 endPackageIndex,
        address[] calldata users
    ) external onlyOwner {
        uint256 startPackageIndex;
        for (uint256 j = 0; j < users.length; j++) {
            startPackageIndex = userPackages[users[j]] + 1;
            require(
                startPackageIndex > 0 &&
                    endPackageIndex < packagePrices.length &&
                    startPackageIndex <= endPackageIndex,
                "Invalid package indexes"
            );

            for (uint256 i = startPackageIndex; i <= endPackageIndex; i++) {
                providePackage(i, users[j]);
            }
        }
    }

    function clearDownlines(
        address uplineToRecycle,
        address uplineOfUpline2,
        uint256 packageIndex
    ) internal {
        address[] storage downlineAddresses = downlines[packageIndex][
            uplineOfUpline2
        ];

        // Find the index of upline2 in the downlineAddresses array
        uint256 indexToDelete;
        for (uint256 i = 0; i < downlineAddresses.length; i++) {
            if (downlineAddresses[i] == uplineToRecycle) {
                indexToDelete = i;
                break;
            }
        }
        // If upline2 was found, "delete" it by setting the address to 0
        if (indexToDelete < downlineAddresses.length) {
            downlineAddresses[indexToDelete] = address(0);
        }
        downlines[packageIndex][uplineToRecycle] = new address[](0);
    }

    function clearSecondLayerDownlines(
        address uplineToRecycle,
        address secUplineOfUpline2,
        uint256 packageIndex
    ) internal {
        address[] storage secdownlineAddresses = secondLayerDownlines[
            packageIndex
        ][secUplineOfUpline2];

        // Find the index of upline2 in the downlineAddresses array
        uint256 indexToDelete;
        for (uint256 i = 0; i < secdownlineAddresses.length; i++) {
            if (secdownlineAddresses[i] == uplineToRecycle) {
                indexToDelete = i;
                break;
            }
        }
        // If upline2 was found, "delete" it by setting the address to 0
        if (indexToDelete < secdownlineAddresses.length) {
            secdownlineAddresses[indexToDelete] = address(0);
        }
        secondLayerDownlines[packageIndex][uplineToRecycle] = new address[](0);
    }

    function withdrawUSDT(uint256 amount) public onlyOwner {
        usdtToken.transfer(owner(), amount);
    }

    function recycleProcess(
        uint256 packageIndex,
        uint256 remaining,
        address structureUpline2
    ) internal {
        address UplineOfStructure2 = upline[packageIndex][structureUpline2];
        address uplineToUplineOfStructure2 = upline[packageIndex][
            upline[packageIndex][structureUpline2]
        ];
        uint256 packagePrice = packagePrices[packageIndex];

        if (
            (secondLayerDownlines[packageIndex][structureUpline2].length ==
                16) && (structureUpline2 == owner())
        ) {
            downlines[packageIndex][owner()] = new address[](0);
            secondLayerDownlines[packageIndex][owner()] = new address[](0);
            emit PackagePurchased(
                owner(),
                packageIndex,
                packagePrice,
                address(0),
                address(0),
                address(0),
                address(0),
                address(0),
                false,
                false,
                true,
                address(0),
                address(0)
            );
        }

        if (
            (secondLayerDownlines[packageIndex][structureUpline2].length ==
                16) && (UplineOfStructure2 != address(0))
        ) {
            if (downlines[packageIndex][UplineOfStructure2].length < 4) {
                downlines[packageIndex][UplineOfStructure2].push(
                    structureUpline2
                );
                if (UplineOfStructure2 != owner()) {
                    secondLayerDownlines[packageIndex][
                        uplineToUplineOfStructure2
                    ].push(structureUpline2);
                }
                usdtToken.transfer(UplineOfStructure2, remaining / 2);

                clearDownlines(
                    structureUpline2,
                    UplineOfStructure2,
                    packageIndex
                );
                clearSecondLayerDownlines(
                    structureUpline2,
                    uplineToUplineOfStructure2,
                    packageIndex
                );

                uint256 secondaryLine = secondLayerDownlines[packageIndex][
                    uplineToUplineOfStructure2
                ].length;

                if (secondaryLine == 16) {
                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        false,
                        false,
                        true,
                        UplineOfStructure2,
                        uplineToUplineOfStructure2
                    );
                }

                if (secondaryLine >= 1 && secondaryLine <= 3) {
                    usdtToken.transfer(RoyaltyContract, remaining / 2);

                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        true,
                        false,
                        false,
                        UplineOfStructure2,
                        uplineToUplineOfStructure2
                    );
                } else if (secondaryLine >= 4 && secondaryLine <= 14) {
                    usdtToken.transfer(
                        uplineToUplineOfStructure2,
                        remaining / 2
                    );

                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        false,
                        false,
                        false,
                        UplineOfStructure2,
                        uplineToUplineOfStructure2
                    );
                } else if (secondaryLine == 16) {
                    recycleProcess(
                        packageIndex,
                        remaining,
                        uplineToUplineOfStructure2
                    );
                }
            } else {
                for (
                    uint256 i = 0;
                    i < downlines[packageIndex][UplineOfStructure2].length;
                    i++
                ) {
                    address downlineOfUplineOfStructure2 = downlines[
                        packageIndex
                    ][UplineOfStructure2][i];
                    if (
                        downlines[packageIndex][downlineOfUplineOfStructure2]
                            .length < 4
                    ) {
                        downlines[packageIndex][downlineOfUplineOfStructure2]
                            .push(structureUpline2);
                        upline[packageIndex][
                            structureUpline2
                        ] = downlineOfUplineOfStructure2;
                        uplineToUplineOFStructureUpline2 = payable(
                            upline[packageIndex][downlineOfUplineOfStructure2]
                        );

                        if (downlineOfUplineOfStructure2 != owner()) {
                            secondLayerDownlines[packageIndex][
                                UplineOfStructure2
                            ].push(structureUpline2);
                        }
                        usdtToken.transfer(
                            downlineOfUplineOfStructure2,
                            remaining / 2
                        );

                        clearDownlines(
                            structureUpline2,
                            UplineOfStructure2,
                            packageIndex
                        );
                        clearSecondLayerDownlines(
                            structureUpline2,
                            uplineToUplineOfStructure2,
                            packageIndex
                        );

                        uint256 secondaryLine = secondLayerDownlines[
                            packageIndex
                        ][UplineOfStructure2].length;

                        if (secondaryLine == 16) {
                            emit PackagePurchased(
                                structureUpline2,
                                packageIndex,
                                packagePrice,
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                false,
                                false,
                                true,
                                downlineOfUplineOfStructure2,
                                uplineToUplineOFStructureUpline2
                            );
                        }

                        if (secondaryLine >= 1 && secondaryLine <= 3) {
                            emit PackagePurchased(
                                structureUpline2,
                                packageIndex,
                                packagePrice,
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                true,
                                false,
                                false,
                                downlineOfUplineOfStructure2,
                                uplineToUplineOFStructureUpline2
                            );
                        } else if (secondaryLine >= 4 && secondaryLine <= 14) {
                            emit PackagePurchased(
                                structureUpline2,
                                packageIndex,
                                packagePrice,
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                false,
                                false,
                                false,
                                downlineOfUplineOfStructure2,
                                uplineToUplineOFStructureUpline2
                            );
                        } else if (secondaryLine == 16) {
                            recycleProcess(
                                packageIndex,
                                remaining,
                                uplineToUplineOFStructureUpline2
                            );
                        }
                        break;
                    }
                }
            }
        }
    }

    function recycleProvidePackage(
        uint256 packageIndex,
        address structureUpline2
    ) internal {
        address UplineOfStructure2 = upline[packageIndex][structureUpline2];
        address uplineToUplineOfStructure2 = upline[packageIndex][
            upline[packageIndex][structureUpline2]
        ];
        uint256 packagePrice = packagePrices[packageIndex];

        if (
            (secondLayerDownlines[packageIndex][structureUpline2].length ==
                16) && (structureUpline2 == owner())
        ) {
            downlines[packageIndex][owner()] = new address[](0);
            secondLayerDownlines[packageIndex][owner()] = new address[](0);
            emit PackagePurchased(
                owner(),
                packageIndex,
                packagePrice,
                address(0),
                address(0),
                address(0),
                address(0),
                address(0),
                false,
                false,
                true,
                address(0),
                address(0)
            );
        }

        if (
            (secondLayerDownlines[packageIndex][structureUpline2].length ==
                16) && (UplineOfStructure2 != address(0))
        ) {
            if (downlines[packageIndex][UplineOfStructure2].length < 4) {
                downlines[packageIndex][UplineOfStructure2].push(
                    structureUpline2
                );
                if (UplineOfStructure2 != owner()) {
                    secondLayerDownlines[packageIndex][
                        uplineToUplineOfStructure2
                    ].push(structureUpline2);
                }

                clearDownlines(
                    structureUpline2,
                    UplineOfStructure2,
                    packageIndex
                );
                clearSecondLayerDownlines(
                    structureUpline2,
                    uplineToUplineOfStructure2,
                    packageIndex
                );

                uint256 secondaryLine = secondLayerDownlines[packageIndex][
                    uplineToUplineOfStructure2
                ].length;

                if (secondaryLine == 16) {
                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        false,
                        false,
                        true,
                        UplineOfStructure2,
                        uplineToUplineOfStructure2
                    );
                }

                if (secondaryLine >= 1 && secondaryLine <= 3) {
                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        true,
                        false,
                        false,
                        UplineOfStructure2,
                        uplineToUplineOfStructure2
                    );
                } else if (secondaryLine >= 4 && secondaryLine <= 14) {
                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        false,
                        false,
                        false,
                        UplineOfStructure2,
                        uplineToUplineOfStructure2
                    );
                } else if (secondaryLine == 16) {
                    recycleProvidePackage(
                        packageIndex,
                        uplineToUplineOfStructure2
                    );
                }
            } else {
                for (
                    uint256 i = 0;
                    i < downlines[packageIndex][UplineOfStructure2].length;
                    i++
                ) {
                    address downlineOfUplineOfStructure2 = downlines[
                        packageIndex
                    ][UplineOfStructure2][i];
                    if (
                        downlines[packageIndex][downlineOfUplineOfStructure2]
                            .length < 4
                    ) {
                        downlines[packageIndex][downlineOfUplineOfStructure2]
                            .push(structureUpline2);
                        upline[packageIndex][
                            structureUpline2
                        ] = downlineOfUplineOfStructure2;
                        uplineToUplineOFStructureUpline2 = payable(
                            upline[packageIndex][downlineOfUplineOfStructure2]
                        );

                        if (downlineOfUplineOfStructure2 != owner()) {
                            secondLayerDownlines[packageIndex][
                                UplineOfStructure2
                            ].push(structureUpline2);
                        }

                        clearDownlines(
                            structureUpline2,
                            UplineOfStructure2,
                            packageIndex
                        );
                        clearSecondLayerDownlines(
                            structureUpline2,
                            uplineToUplineOfStructure2,
                            packageIndex
                        );

                        uint256 secondaryLine = secondLayerDownlines[
                            packageIndex
                        ][UplineOfStructure2].length;

                        if (secondaryLine == 16) {
                            emit PackagePurchased(
                                structureUpline2,
                                packageIndex,
                                packagePrice,
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                false,
                                false,
                                true,
                                downlineOfUplineOfStructure2,
                                uplineToUplineOFStructureUpline2
                            );
                        }

                        if (secondaryLine >= 1 && secondaryLine <= 3) {
                            emit PackagePurchased(
                                structureUpline2,
                                packageIndex,
                                packagePrice,
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                true,
                                false,
                                false,
                                downlineOfUplineOfStructure2,
                                uplineToUplineOFStructureUpline2
                            );
                        } else if (secondaryLine >= 4 && secondaryLine <= 14) {
                            emit PackagePurchased(
                                structureUpline2,
                                packageIndex,
                                packagePrice,
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                false,
                                false,
                                false,
                                downlineOfUplineOfStructure2,
                                uplineToUplineOFStructureUpline2
                            );
                        } else if (secondaryLine == 16) {
                            recycleProvidePackage(
                                packageIndex,
                                uplineToUplineOFStructureUpline2
                            );
                        }

                        break;
                    }
                }
            }
        }
    }

    function setStructureUpline1(
        address user,
        address _structure1Upline,
        uint256 packageIndex
    ) external onlyOwner {
        upline[packageIndex][user] = payable(_structure1Upline);
    }

    function removeAddressFromSecLine(
        uint256 index,
        uint256 packageIndex,
        address user
    ) external onlyOwner {
        require(
            index < secondLayerDownlines[packageIndex][user].length,
            "Index out of bounds"
        );

        // Shift addresses back to fill the gap
        for (
            uint256 i = index;
            i < secondLayerDownlines[packageIndex][user].length - 1;
            i++
        ) {
            secondLayerDownlines[packageIndex][user][i] = secondLayerDownlines[
                packageIndex
            ][user][i + 1];
        }

        // Remove the last address
        secondLayerDownlines[packageIndex][user].pop();
    }

    function addAddressInSecLine(
        uint256 index,
        uint256 packageIndex,
        address user,
        address newAddress
    ) external onlyOwner {
        require(
            index <= secondLayerDownlines[packageIndex][user].length,
            "Index out of bounds"
        );

        // Shift addresses forward to make space for the new address
        secondLayerDownlines[packageIndex][user].push(); // Add a new element at the end
        for (
            uint256 i = secondLayerDownlines[packageIndex][user].length - 1;
            i > index;
            i--
        ) {
            secondLayerDownlines[packageIndex][user][i] = secondLayerDownlines[
                packageIndex
            ][user][i - 1];
        }

        // Add the new address at the specified index
        secondLayerDownlines[packageIndex][user][index] = newAddress;
    }

    function clearDownlinesByOwner(address user, uint256 packageIndex)
        public
        onlyOwner
    {
        downlines[packageIndex][user] = new address[](0);
    }

    function clearSecondaryDownlinesByOwner(address user, uint256 packageIndex)
        public
        onlyOwner
    {
        secondLayerDownlines[packageIndex][user] = new address[](0);
    }

    function setPackage(address payable user, uint256 _setPackage)
        external
        onlyOwner
    {
        userPackages[user] = _setPackage;
    }
}

contract Power_Matrix is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    IERC20 public usdtToken;
    address payable public RoyaltyContract;
    RegistrationInterface public registration;
    Pro_Power_Matrix public Pro;

    // Declare payable addresses for upline
    address payable public upline1;
    address payable public upline2;
    address payable public upline3;
    address payable public upline4;
    address payable public upline5;
    address payable public structureUpline1;
    address payable public structureUpline2;
    address payable public uplineToUplineOFStructureUpline2;
    address payable public recycleUplineToUplineOFStructureUpline2;

    uint256[] public packagePrices;
    mapping(address => uint8) public userPackages;

    // Constants for distribution percentages

    mapping(uint8 => mapping(address => address)) public upline;
    mapping(uint8 => mapping(address => address[])) public downlines;
    mapping(uint8 => mapping(address => uint8)) public secondLayerDownlines;

    event PackagePurchased(
        address indexed user,
        uint256 packageIndex,
        uint256 price,
        address upline1,
        address upline2,
        address upline3,
        address upline4,
        address upline5,
        bool royalty,
        bool recycle15,
        bool recycle16,
        address structureUpline1,
        address structureUpline2
    );

    receive() external payable {}

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();

        packagePrices.push(0);
        packagePrices.push(5 * 10**18);
        packagePrices.push(8 * 10**18);
        packagePrices.push(14 * 10**18);
        packagePrices.push(26 * 10**18);
        packagePrices.push(50 * 10**18);
        packagePrices.push(98 * 10**18);
        packagePrices.push(194 * 10**18);
        packagePrices.push(386 * 10**18);
        packagePrices.push(770 * 10**18);
        packagePrices.push(1538 * 10**18);
        packagePrices.push(3074 * 10**18);
        packagePrices.push(6146 * 10**18);

        upline1 = payable(owner());
        upline2 = payable(owner());
        upline3 = payable(owner());
        upline4 = payable(owner());
        upline5 = payable(owner());
        structureUpline1 = payable(owner());
        structureUpline2 = payable(owner());
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    function setRegistration(address _registrationAddress) external onlyOwner {
        registration = RegistrationInterface(_registrationAddress);
    }

    function setRoyalty(address _royalty) external onlyOwner {
        RoyaltyContract = payable(_royalty);
    }

    function setUSDT(address _usdtToken) external onlyOwner {
        usdtToken = IERC20(_usdtToken);
    }

    function setPro(address payable _pro) external onlyOwner {
        Pro = Pro_Power_Matrix(_pro);
    }

    function setPackage(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            uint8 packageUser = uint8(Pro.userPackages(user));
            if (packageUser != 0) {
                userPackages[user] = packageUser;
            }
        }
    }

    function getAllDownlines(uint256 packageIndex, address user)
        internal
        view
        returns (address[] memory)
    {
        address[] memory allResults = new address[](0); // Initialize an array to store the results
        for (uint256 pos = 0; pos < 4; pos++) {
            try Pro.downlines(packageIndex, user, pos) returns (
                address downlineuser
            ) {
                allResults = appendToAddressArray(allResults, downlineuser);
            } catch {
                break;
            }
        }
        return allResults;
    }

    function getAllSecondaryDownlines(uint256 packageIndex, address user)
        internal
        view
        returns (uint8)
    {
        for (uint8 pos = 0; pos < 16; pos++) {
            try Pro.secondLayerDownlines(packageIndex, user, pos) returns (
                address downlineuser
            ) {} catch {
                return pos;
            }
        }
    }

    function appendToAddressArray(address[] memory array, address element)
        private
        pure
        returns (address[] memory)
    {
        address[] memory newArray = new address[](array.length + 1);
        for (uint256 i = 0; i < array.length; i++) {
            newArray[i] = array[i];
        }
        newArray[array.length] = element;
        return newArray;
    }

    function setUserUpline(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];

            uint256 package = userPackages[user];

            for (uint8 i = 1; i <= package; i++) {
                address _structure1Upline = Pro.upline(i, user);
                upline[i][user] = _structure1Upline;
            }
        }
    }

    function setDownlinesForUsers(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            uint256 pack = userPackages[user];

            for (uint8 j = 1; j <= pack; j++) {
                address[] memory downline = getAllDownlines(j, user);
                downlines[j][user] = downline;
                if (downline.length != 0) {
                    secondLayerDownlines[j][user] = getAllSecondaryDownlines(
                        j,
                        user
                    );
                }
            }
        }
    }

    function updateAndSetDistributionAddresses(
        address currentUpline,
        uint256 packageIndex
    ) internal {
        address userUpline = currentUpline;

        uint256 qualifiedUplinesFound = 0;

        // Iterate through uplines until 5 qualified uplines are found or until the user's package index is greater than or equal to the upline's package index
        while (userUpline != address(0) && qualifiedUplinesFound < 5) {
            if (userPackages[userUpline] >= packageIndex) {
                qualifiedUplinesFound++;

                if (qualifiedUplinesFound == 1) {
                    upline1 = payable(userUpline);
                } else if (qualifiedUplinesFound == 2) {
                    upline2 = payable(userUpline);
                } else if (qualifiedUplinesFound == 3) {
                    upline3 = payable(userUpline);
                } else if (qualifiedUplinesFound == 4) {
                    upline4 = payable(userUpline);
                } else if (qualifiedUplinesFound == 5) {
                    upline5 = payable(userUpline);
                }
            }

            // Move up to the next referrer
            address referrer = registration.getUserInfo(userUpline).referrer;
            while (
                referrer != address(0) && userPackages[referrer] < packageIndex
            ) {
                referrer = registration.getUserInfo(referrer).referrer;
            }

            if (referrer == address(0)) {
                break; // Break the loop if no referrer with a matching or higher package index is found
            }

            userUpline = referrer;
        }

        // If upline1, upline2, upline3, upline4, or upline5 are not set, set them to the contract owner
        if (qualifiedUplinesFound < 1) {
            upline1 = payable(owner());
        }

        if (qualifiedUplinesFound < 2) {
            upline2 = payable(owner());
        }

        if (qualifiedUplinesFound < 3) {
            upline3 = payable(owner());
        }

        if (qualifiedUplinesFound < 4) {
            upline4 = payable(owner());
        }

        if (qualifiedUplinesFound < 5) {
            upline5 = payable(owner());
        }
    }

    function purchasePackage(uint8 packageIndex) external {
        require(
            packageIndex > 0 && packageIndex < packagePrices.length,
            "Invalid package index"
        );

        uint256 currentPackageIndex = userPackages[msg.sender];

        // Check if the user has any existing package or if they are purchasing the next package in sequence
        require(
            packageIndex == currentPackageIndex + 1,
            "Purchase packages sequentially"
        );

        uint256 packagePrice = packagePrices[packageIndex];

        usdtToken.approve(address(this), packagePrice);

        // Transfer USDT from the user to the contract
        usdtToken.transferFrom(msg.sender, address(this), packagePrice);

        // Check if the user is registered
        require(
            registration.getUserInfo(msg.sender).isRegistered,
            "Not registered"
        );

        address referrerAddress = registration.getUserInfo(msg.sender).referrer;
        upline[packageIndex][msg.sender] = referrerAddress;

        // Check if the referrer address is valid
        require(referrerAddress != address(0), "Referrer not found");

        updateAndSetDistributionAddresses(referrerAddress, packageIndex);

        // Distribute 2 USDT among levels 1 to 5 (deducted from the package price)
        distribute2USDT();

        uint256 remainingAmount = packagePrice - 2 * 10**18;

        // Check if the specified upline already has 4 downlines
        if (downlines[packageIndex][upline1].length < 4) {
            downlines[packageIndex][upline1].push(msg.sender);
            upline[packageIndex][msg.sender] = upline1;
            structureUpline1 = upline1;
            structureUpline2 = payable(upline[packageIndex][structureUpline1]);

            if (upline1 != owner()) {
                secondLayerDownlines[packageIndex][structureUpline2]++;
            }
        } else {
            for (
                uint256 i = 0;
                i < downlines[packageIndex][upline1].length;
                i++
            ) {
                address downlineAddress = downlines[packageIndex][upline1][i];
                if (downlineAddress != address(0)) {
                    if (downlines[packageIndex][downlineAddress].length < 4) {
                        downlines[packageIndex][downlineAddress].push(
                            msg.sender
                        );
                        upline[packageIndex][msg.sender] = downlineAddress;
                        structureUpline1 = payable(downlineAddress);
                        structureUpline2 = payable(
                            upline[packageIndex][downlineAddress]
                        );

                        if (downlineAddress != owner()) {
                            secondLayerDownlines[packageIndex][
                                structureUpline2
                            ]++;
                        }
                        break;
                    }
                }
            }
        }
        usdtToken.transfer(structureUpline1, remainingAmount / 2);
        distributeUSDT(structureUpline2, remainingAmount / 2, packageIndex);
        if (secondLayerDownlines[packageIndex][structureUpline2] == 16) {
            emit PackagePurchased(
                msg.sender,
                packageIndex,
                packagePrice,
                upline1,
                upline2,
                upline3,
                upline4,
                upline5,
                false,
                false,
                true,
                structureUpline1,
                structureUpline2
            );
        }
        if (secondLayerDownlines[packageIndex][structureUpline2] == 16) {
            recycleProcess(packageIndex, remainingAmount, structureUpline2);
        }

        // Remove the user from the downlines of their previous upline
        userPackages[msg.sender] = packageIndex;
    }

    function recycleProcess(
        uint8 packageIndex,
        uint256 remaining,
        address structureUpline2
    ) internal {
        address UplineOfStructure2 = upline[packageIndex][structureUpline2];

        address referrerAddress = registration
            .getUserInfo(structureUpline2)
            .referrer;
        updateAndSetDistributionAddresses(referrerAddress, packageIndex);
        address newUpline = upline1;
        address newUpllineOfUplineStructure2 = upline[packageIndex][newUpline];
        uint256 packagePrice = packagePrices[packageIndex];

        if (
            (secondLayerDownlines[packageIndex][structureUpline2] == 16) &&
            (structureUpline2 == owner())
        ) {
            downlines[packageIndex][owner()] = new address[](0);
            secondLayerDownlines[packageIndex][owner()] = 0;

            emit PackagePurchased(
                owner(),
                packageIndex,
                packagePrice,
                address(0),
                address(0),
                address(0),
                address(0),
                address(0),
                false,
                false,
                true,
                address(0),
                address(0)
            );
        }

        if (
            (secondLayerDownlines[packageIndex][structureUpline2] == 16) &&
            (newUpline != address(0))
        ) {
            if (downlines[packageIndex][newUpline].length < 4) {
                downlines[packageIndex][newUpline].push(structureUpline2);
                if (newUpline != owner()) {
                    secondLayerDownlines[packageIndex][
                        newUpllineOfUplineStructure2
                    ]++;
                }
                usdtToken.transfer(newUpline, remaining / 2);

                clearDownlines(
                    structureUpline2,
                    UplineOfStructure2,
                    packageIndex
                );
                clearSecondLayerDownlines(structureUpline2, packageIndex);

                uint256 secondaryLine = secondLayerDownlines[packageIndex][
                    newUpllineOfUplineStructure2
                ];

                if (secondaryLine >= 1 && secondaryLine <= 3) {
                    usdtToken.transfer(RoyaltyContract, remaining / 2);

                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        true,
                        false,
                        false,
                        newUpline,
                        newUpllineOfUplineStructure2
                    );
                } else if (secondaryLine >= 4 && secondaryLine <= 14) {
                    usdtToken.transfer(
                        newUpllineOfUplineStructure2,
                        remaining / 2
                    );

                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        false,
                        false,
                        false,
                        newUpline,
                        newUpllineOfUplineStructure2
                    );
                } else if (secondaryLine == 15) {
                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        false,
                        true,
                        false,
                        newUpline,
                        newUpllineOfUplineStructure2
                    );
                } else if (secondaryLine == 16) {
                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        false,
                        false,
                        true,
                        newUpline,
                        newUpllineOfUplineStructure2
                    );
                    recycleProcess(
                        packageIndex,
                        remaining,
                        newUpllineOfUplineStructure2
                    );
                }
            } else {
                clearDownlines(
                    structureUpline2,
                    UplineOfStructure2,
                    packageIndex
                );
                clearSecondLayerDownlines(structureUpline2, packageIndex);

                for (
                    uint256 i = 0;
                    i < downlines[packageIndex][newUpline].length;
                    i++
                ) {
                    address downlineOfnewUplineOfStructure2 = downlines[
                        packageIndex
                    ][newUpline][i];

                    if (downlineOfnewUplineOfStructure2 == address(0)) {
                        continue;
                    }

                    if (
                        downlines[packageIndex][downlineOfnewUplineOfStructure2]
                            .length < 4
                    ) {
                        downlines[packageIndex][downlineOfnewUplineOfStructure2]
                            .push(structureUpline2);

                        upline[packageIndex][
                            structureUpline2
                        ] = downlineOfnewUplineOfStructure2;

                        uplineToUplineOFStructureUpline2 = payable(
                            upline[packageIndex][
                                downlineOfnewUplineOfStructure2
                            ]
                        );

                        if (downlineOfnewUplineOfStructure2 != owner()) {
                            secondLayerDownlines[packageIndex][newUpline]++;
                        }
                        usdtToken.transfer(
                            downlineOfnewUplineOfStructure2,
                            remaining / 2
                        );

                        uint256 secondaryLine = secondLayerDownlines[
                            packageIndex
                        ][newUpline];

                        if (secondaryLine >= 1 && secondaryLine <= 3) {
                            usdtToken.transfer(RoyaltyContract, remaining / 2);

                            emit PackagePurchased(
                                structureUpline2,
                                packageIndex,
                                packagePrice,
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                true,
                                false,
                                false,
                                downlineOfnewUplineOfStructure2,
                                uplineToUplineOFStructureUpline2
                            );
                        } else if (secondaryLine >= 4 && secondaryLine <= 14) {
                            usdtToken.transfer(
                                uplineToUplineOFStructureUpline2,
                                remaining / 2
                            );

                            emit PackagePurchased(
                                structureUpline2,
                                packageIndex,
                                packagePrice,
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                false,
                                false,
                                false,
                                downlineOfnewUplineOfStructure2,
                                uplineToUplineOFStructureUpline2
                            );
                        } else if (secondaryLine == 15) {
                            emit PackagePurchased(
                                structureUpline2,
                                packageIndex,
                                packagePrice,
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                false,
                                true,
                                false,
                                downlineOfnewUplineOfStructure2,
                                uplineToUplineOFStructureUpline2
                            );
                        } else if (secondaryLine == 16) {
                            emit PackagePurchased(
                                structureUpline2,
                                packageIndex,
                                packagePrice,
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                false,
                                false,
                                true,
                                downlineOfnewUplineOfStructure2,
                                uplineToUplineOFStructureUpline2
                            );
                            recycleProcess(
                                packageIndex,
                                remaining,
                                uplineToUplineOFStructureUpline2
                            );
                        }
                        break;
                    }
                }
            }
        }
    }

    function distribute2USDT() internal {
        uint256 usdtToDistribute = 2 * 10**18; // 2 USDT

        // Transfer USDT to levels
        usdtToken.transfer(upline1, (usdtToDistribute * 40) / 100);
        usdtToken.transfer(upline2, (usdtToDistribute * 25) / 100);
        usdtToken.transfer(upline3, (usdtToDistribute * 15) / 100);
        usdtToken.transfer(upline4, (usdtToDistribute * 10) / 100);
        usdtToken.transfer(upline5, (usdtToDistribute * 10) / 100);
    }

    function distributeUSDT(
        address StructureUpline2,
        uint256 amountToDistribute,
        uint8 packageIndex
    ) internal {
        uint256 i = secondLayerDownlines[packageIndex][StructureUpline2];

        uint256 packagePrice = packagePrices[packageIndex];
        // Distribute USDT according to the conditions
        if (i == 0) {
            emit PackagePurchased(
                msg.sender,
                packageIndex,
                packagePrice,
                upline1,
                upline2,
                upline3,
                upline4,
                upline5,
                false,
                false,
                false,
                structureUpline1,
                structureUpline2
            );
        } else if (i >= 1 && i <= 3) {
            // Distribute to RoyaltyContract for the first 3 downlines
            usdtToken.transfer(RoyaltyContract, amountToDistribute);
            emit PackagePurchased(
                msg.sender,
                packageIndex,
                packagePrice,
                upline1,
                upline2,
                upline3,
                upline4,
                upline5,
                true,
                false,
                false,
                structureUpline1,
                structureUpline2
            );
        } else if (i >= 4 && i <= 14) {
            // Distribute to upline2 for downlines 4 to 13
            usdtToken.transfer(structureUpline2, amountToDistribute);
            emit PackagePurchased(
                msg.sender,
                packageIndex,
                packagePrice,
                upline1,
                upline2,
                upline3,
                upline4,
                upline5,
                false,
                false,
                false,
                structureUpline1,
                structureUpline2
            );
        } else if (i == 15) {
            // Distribute to upline3 and upline4 for downlines 14
            usdtToken.transfer(address(this), amountToDistribute);

            emit PackagePurchased(
                msg.sender,
                packageIndex,
                packagePrice,
                upline1,
                upline2,
                upline3,
                upline4,
                upline5,
                false,
                true,
                false,
                structureUpline1,
                structureUpline2
            );
        }
    }

    function clearDownlines(
        address uplineToRecycle,
        address uplineOfUpline2,
        uint8 packageIndex
    ) internal {
        address[] storage downlineAddresses = downlines[packageIndex][
            uplineOfUpline2
        ];

        // Find the index of upline2 in the downlineAddresses array
        uint256 indexToDelete;
        for (uint256 i = 0; i < downlineAddresses.length; i++) {
            if (downlineAddresses[i] == uplineToRecycle) {
                indexToDelete = i;
                break;
            }
        }
        // If upline2 was found, "delete" it by setting the address to 0
        if (indexToDelete < downlineAddresses.length) {
            downlineAddresses[indexToDelete] = address(0);
        }
        downlines[packageIndex][uplineToRecycle] = new address[](0);
    }

    function clearSecondLayerDownlines(
        address uplineToRecycle,
        uint8 packageIndex
    ) internal {
        secondLayerDownlines[packageIndex][uplineToRecycle] = 0;
    }

    function providePackage(uint8 packageIndex, address user)
        internal
        onlyOwner
    {
        require(
            packageIndex > 0 && packageIndex < packagePrices.length,
            "Invalid package index"
        );

        uint8 currentPackageIndex = userPackages[user];

        // Check if the user has any existing package or if they are purchasing the next package in sequence
        require(
            packageIndex == currentPackageIndex + 1,
            "Must provide packages sequentially"
        );

        // Check if the user is registered
        require(
            registration.getUserInfo(user).isRegistered,
            "User is not registered"
        );

        address referrerAddress = registration.getUserInfo(user).referrer;

        // Check if the referrer address is valid
        require(referrerAddress != address(0), "Referrer not found");

        upline[packageIndex][user] = referrerAddress;

        updateAndSetDistributionAddresses(referrerAddress, packageIndex);

        // Check if the specified upline already has 4 downlines
        if (downlines[packageIndex][upline1].length < 4) {
            downlines[packageIndex][upline1].push(user);
            upline[packageIndex][user] = upline1;
            structureUpline1 = upline1;
            structureUpline2 = payable(upline[packageIndex][structureUpline1]);

            if (upline1 != owner()) {
                secondLayerDownlines[packageIndex][structureUpline2]++;
            }
        } else {
            for (
                uint256 j = 0;
                j < downlines[packageIndex][upline1].length;
                j++
            ) {
                address downlineAddress = downlines[packageIndex][upline1][j];
                if (downlineAddress != address(0)) {
                    if (downlines[packageIndex][downlineAddress].length < 4) {
                        downlines[packageIndex][downlineAddress].push(user);
                        upline[packageIndex][user] = downlineAddress;
                        structureUpline1 = payable(downlineAddress);
                        structureUpline2 = payable(
                            upline[packageIndex][downlineAddress]
                        );
                        if (structureUpline1 != owner()) {
                            secondLayerDownlines[packageIndex][
                                structureUpline2
                            ]++;
                        }
                        break;
                    }
                }
            }
        }

        uint8 secondLayer = secondLayerDownlines[packageIndex][
            structureUpline2
        ];
        uint256 i = secondLayer;
        uint256 packagePrice = packagePrices[packageIndex];

        if (secondLayer <= 16) {
            if (i == 0) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i >= 1 && i <= 3) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    true,
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i >= 4 && i <= 14) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i == 15) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    true,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i == 16) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    false,
                    true,
                    structureUpline1,
                    structureUpline2
                );
            }
        }
        if (secondLayer == 16) {
            recycleProvidePackage(packageIndex, structureUpline2);
        }
        userPackages[user] = packageIndex;
    }

    function ProvidePackagesBulk(
        uint8 endPackageIndex,
        address[] calldata users
    ) external onlyOwner {
        uint8 startPackageIndex;
        for (uint8 j = 0; j < users.length; j++) {
            startPackageIndex = userPackages[users[j]] + 1;
            require(
                startPackageIndex > 0 &&
                    endPackageIndex < packagePrices.length &&
                    startPackageIndex <= endPackageIndex,
                "Invalid package indexes"
            );

            for (uint8 i = startPackageIndex; i <= endPackageIndex; i++) {
                providePackage(i, users[j]);
            }
        }
    }

    function recycleProvidePackage(uint8 packageIndex, address structureUpline2)
        internal
    {
        address UplineOfStructure2 = upline[packageIndex][structureUpline2];

        address referrerAddress = registration
            .getUserInfo(structureUpline2)
            .referrer;
        updateAndSetDistributionAddresses(referrerAddress, packageIndex);
        address newUpline = upline1;
        address newUpllineOfUplineStructure2 = upline[packageIndex][newUpline];

        uint256 packagePrice = packagePrices[packageIndex];

        if (
            (secondLayerDownlines[packageIndex][structureUpline2] == 16) &&
            (structureUpline2 == owner())
        ) {
            downlines[packageIndex][owner()] = new address[](0);
            secondLayerDownlines[packageIndex][owner()] = 0;
            emit PackagePurchased(
                owner(),
                packageIndex,
                packagePrice,
                address(0),
                address(0),
                address(0),
                address(0),
                address(0),
                false,
                false,
                true,
                address(0),
                address(0)
            );
        }

        if (
            (secondLayerDownlines[packageIndex][structureUpline2] == 16) &&
            (newUpline != address(0))
        ) {
            if (downlines[packageIndex][newUpline].length < 4) {
                downlines[packageIndex][newUpline].push(structureUpline2);
                if (newUpline != owner()) {
                    secondLayerDownlines[packageIndex][
                        newUpllineOfUplineStructure2
                    ]++;
                }

                clearDownlines(
                    structureUpline2,
                    UplineOfStructure2,
                    packageIndex
                );
                clearSecondLayerDownlines(structureUpline2, packageIndex);

                uint256 secondaryLine = secondLayerDownlines[packageIndex][
                    newUpllineOfUplineStructure2
                ];

                if (secondaryLine >= 1 && secondaryLine <= 3) {
                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        true,
                        false,
                        false,
                        newUpline,
                        newUpllineOfUplineStructure2
                    );
                } else if (secondaryLine >= 4 && secondaryLine <= 14) {
                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        false,
                        false,
                        false,
                        newUpline,
                        newUpllineOfUplineStructure2
                    );
                } else if (secondaryLine == 15) {
                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        false,
                        true,
                        false,
                        newUpline,
                        newUpllineOfUplineStructure2
                    );
                } else if (secondaryLine == 16) {
                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        false,
                        false,
                        true,
                        newUpline,
                        newUpllineOfUplineStructure2
                    );

                    recycleProvidePackage(
                        packageIndex,
                        newUpllineOfUplineStructure2
                    );
                }
            } else {
                clearDownlines(
                    structureUpline2,
                    UplineOfStructure2,
                    packageIndex
                );
                clearSecondLayerDownlines(structureUpline2, packageIndex);

                for (
                    uint256 i = 0;
                    i < downlines[packageIndex][newUpline].length;
                    i++
                ) {
                    address downlineOfNewUpline = downlines[packageIndex][
                        newUpline
                    ][i];
                    if (downlineOfNewUpline == address(0)) {
                        continue;
                    }
                    if (
                        downlines[packageIndex][downlineOfNewUpline].length < 4
                    ) {
                        downlines[packageIndex][downlineOfNewUpline].push(
                            structureUpline2
                        );
                        upline[packageIndex][
                            structureUpline2
                        ] = downlineOfNewUpline;
                        newUpllineOfUplineStructure2 = payable(
                            upline[packageIndex][downlineOfNewUpline]
                        );

                        if (downlineOfNewUpline != owner()) {
                            secondLayerDownlines[packageIndex][newUpline]++;
                        }

                        uint256 secondaryLine = secondLayerDownlines[
                            packageIndex
                        ][newUpline];

                        recycleUplineToUplineOFStructureUpline2 = payable(
                            newUpline
                        );

                        if (secondaryLine >= 1 && secondaryLine <= 3) {
                            emit PackagePurchased(
                                structureUpline2,
                                packageIndex,
                                packagePrice,
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                true,
                                false,
                                false,
                                downlineOfNewUpline,
                                recycleUplineToUplineOFStructureUpline2
                            );
                        } else if (secondaryLine >= 4 && secondaryLine <= 14) {
                            emit PackagePurchased(
                                structureUpline2,
                                packageIndex,
                                packagePrice,
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                false,
                                false,
                                false,
                                downlineOfNewUpline,
                                recycleUplineToUplineOFStructureUpline2
                            );
                        } else if (secondaryLine == 15) {
                            emit PackagePurchased(
                                structureUpline2,
                                packageIndex,
                                packagePrice,
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                false,
                                true,
                                false,
                                downlineOfNewUpline,
                                recycleUplineToUplineOFStructureUpline2
                            );
                        } else if (secondaryLine == 16) {
                            emit PackagePurchased(
                                structureUpline2,
                                packageIndex,
                                packagePrice,
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                address(0),
                                false,
                                false,
                                true,
                                downlineOfNewUpline,
                                recycleUplineToUplineOFStructureUpline2
                            );
                            recycleProvidePackage(
                                packageIndex,
                                recycleUplineToUplineOFStructureUpline2
                            );
                        }

                        break;
                    }
                }
            }
        }
    }

    function withdrawUSDT(uint256 amount) external onlyOwner {
        require(amount > 0, "0");
        require(
            usdtToken.balanceOf(address(this)) >= amount,
            "Insufficient USDT balance in contract"
        );
        usdtToken.transfer(owner(), amount);
    }

    function getUSDTBalance() external view onlyOwner returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }

    function setStructureUpline1(
        address user,
        address _structure1Upline,
        uint8 packageIndex
    ) external onlyOwner {
        upline[packageIndex][user] = payable(_structure1Upline);
    }

    function removeAddressFromSecLine(uint8 packageIndex, address user)
        external
        onlyOwner
    {
        secondLayerDownlines[packageIndex][user]--;
    }

    function addAddressInSecLine(uint8 packageIndex, address user)
        external
        onlyOwner
    {
        secondLayerDownlines[packageIndex][user]++;
    }

    function removeAddressFromDownlines(
        uint8 index,
        uint8 packageIndex,
        address user
    ) external onlyOwner {
        require(
            index < downlines[packageIndex][user].length,
            "Index out of bounds"
        );

        // Shift addresses back to fill the gap
        for (
            uint256 i = index;
            i < downlines[packageIndex][user].length - 1;
            i++
        ) {
            downlines[packageIndex][user][i] = downlines[packageIndex][user][
                i + 1
            ];
        }

        // Remove the last address
        downlines[packageIndex][user].pop();
    }

    function addAddressInDownlines(
        uint8 index,
        uint8 packageIndex,
        address user,
        address newAddress
    ) external onlyOwner {
        require(
            index <= downlines[packageIndex][user].length,
            "Index out of bounds"
        );

        // Shift addresses forward to make space for the new address
        downlines[packageIndex][user].push(); // Add a new element at the end
        for (
            uint256 i = downlines[packageIndex][user].length - 1;
            i > index;
            i--
        ) {
            downlines[packageIndex][user][i] = downlines[packageIndex][user][
                i - 1
            ];
        }

        // Add the new address at the specified index
        downlines[packageIndex][user][index] = newAddress;
    }

    function clearDownlinesByOwner(address user, uint8 packageIndex)
        public
        onlyOwner
    {
        downlines[packageIndex][user] = new address[](0);
    }

    function clearSecondaryDownlinesByOwner(address user, uint8 packageIndex)
        public
        onlyOwner
    {
        secondLayerDownlines[packageIndex][user] = 0;
    }

    function setPackage(address payable user, uint8 _setPackage)
        external
        onlyOwner
    {
        userPackages[user] = _setPackage;
    }
}
