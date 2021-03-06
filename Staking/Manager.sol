/**
 * @title Manager
 * @dev Manager contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: GNU GPLv2
 *
 * File: @openzeppelin/contracts/token/ERC20/ERC20.sol
 *
 **/

import "./LPTokenWrapper.sol";
import "./Ownable.sol";
import "./IProxy.sol";

pragma solidity 0.6.12;


contract Manager is LPTokenWrapper, Ownable {

   IProxy public Proxy;

   bool public ProxyTrigger; // is the proxy active or disabled
   address public newProxyContract; // displays the newly submitted proxy contract 
   uint256 public proxyBlockTimelock; // the timelock in blocks you have to wait after updating the proxy to set a new proxy contract on active
   uint256 public lastProxyTimelockBlock; // the last timelock block after the new proxy contract can be activated

    // update the referral contract
    function UpdateReferralsContract(address _referralsContract)
        public
        onlyOwner
    {
        referrals = IReferrals(_referralsContract);
    }

    // update the time frame
    function setTimeFrame(uint256 _timeFrame) public onlyOwner {
       timeFrame = _timeFrame;
       emergencyTime = block.timestamp.add(emergencyTime);
    }

    // update the penalty fee
    function setPenaltyFee(uint256 _penaltyFee) public onlyOwner {
       penaltyFee = _penaltyFee;
       emergencyTime = block.timestamp.add(emergencyTime);
    }

    // update the lock time
    function setLockTime(uint256 _lockTime) public onlyOwner {
       lockTime = _lockTime;
       emergencyTime = block.timestamp.add(emergencyTime);
    }

    // update the ref level reward
    function setRefLevelReward(uint256[] memory _refLevelReward) public onlyOwner {
       refLevelReward = _refLevelReward;
       emergencyTime = block.timestamp.add(emergencyTime);
    }

    // update the max ref levels
    function setRefLevel(uint256 _refLevel) public onlyOwner {
       refLevel = _refLevel;
       emergencyTime = block.timestamp.add(emergencyTime);
    }

    // update the finish period for rewards 
    function setPeriodFinish(uint256 _periodFinish) public onlyOwner {
       periodFinish = _periodFinish;
       emergencyTime = block.timestamp.add(emergencyTime);
    }

    // update the transfer fee from the reward coin 
    function setRewardCoinFee(uint256 _rewardCoinFee) public onlyOwner {
       rewardCoinFee = _rewardCoinFee;
       emergencyTime = block.timestamp.add(emergencyTime);
    }

    // update the free time
    function setFreeTime(uint256 _freeTime) public onlyOwner {
       freeTime = _freeTime;
       emergencyTime = block.timestamp.add(emergencyTime);
    }

    // update the fee reciver address
    function setFeeReciver(address _feeReciver) public onlyOwner {
       feeReciver = _feeReciver;
    }

    // update the vault address
    function setVaultAddress(address _vaultAddress) public onlyOwner {
       vaultAddress = _vaultAddress;
    }

   // update the whitelist contract
   function updateWhitelistContract(address _whitelistContract)
        public
        onlyOwner
    {
        whitelist = IWhitelist(_whitelistContract);
    }

    /**
     * @dev Sets the {proxyBlockTimelock} to define block waiting times.
     *
     * This function ensures that functions cannot be executed immediately
     * but have to wait for a defined block time.
     *
     * Requirements:
     *
     * - only `owner` can update the proxyBlockTimelock
     * - proxyBlockTimelock can only be bigger than last proxyBlockTimelock
     * - proxyBlockTimelock must be lower than 30 days
     *
     */
    function setProxyBlockTimelock(uint256 _setProxyBlockTimelock)
        public
        onlyOwner
    {
        require(
            proxyBlockTimelock < _setProxyBlockTimelock,
            "SAFETY FIRST || proxyBlockTimelock can only be bigger than last blockTimelock"
        );
        require(
            _setProxyBlockTimelock <= 30 days,
            "SAFETY FIRST || proxyBlockTimelock greater than 30 days"
        );
        proxyBlockTimelock = _setProxyBlockTimelock;
    }

    /**
     * @dev Sets the {ProxyTrigger} for transfers.
     *
     * The `owner` decides whether the `ProxyTrigger` is activated or deactivated.
     *
     * Requirements:
     *
     * - only `owner` can update the `ProxyTrigger`
     */
    function setProxyTrigger(bool _ProxyTrigger)
        public
        onlyOwner
    {
        ProxyTrigger = _ProxyTrigger;
    }

    /**
     * @dev Sets `external proxy smart contract`
     *
     * This function shows that the owner wants to update
     * the `ProxyContract` and activates the `lastProxyTimelockBlock`.
     *
     * The new `ProxyContract` is now shown to everyone
     * and people can make the necessary decisions if required.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - only `owner` can update the external smart contracts
     * - `external smart contracts` must be correct and work
     */
    function updateProxyContract(address _ProxyContract)
        public
        onlyOwner
    {
        newProxyContract = _ProxyContract;
        lastProxyTimelockBlock = block.timestamp.add(proxyBlockTimelock);
    }

    /**
     * @dev Activates new `external proxy smart contract`
     *
     * After the `lastProxyTimelockBlock` time has expired
     * The owner can now activate his submitted `external proxy smart contract`
     * and reset the `proxyBlockTimelock` to 1 day.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - only `owner` can update the external smart contracts
     * - `external smart contracts` must be correct and work
     */
    function activateNewProxyContract() public onlyOwner {
        require(
            lastProxyTimelockBlock < block.timestamp,
            "SAFETY FIRST || safetyTimelock smaller than current block"
        );
        Proxy = IProxy(newProxyContract);
        proxyBlockTimelock = 1 days; //Set the update time back to 1 day in case there is an error and you need to intervene quickly.
    }
}
