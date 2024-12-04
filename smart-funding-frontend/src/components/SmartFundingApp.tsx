"use client";

import { useEffect, useState, useCallback } from "react";
import { ethers, Eip1193Provider } from "ethers";

type WalletResponse = string[];

const CONTRACT_ADDRESS = "0xD35Fe7A33565f411dbC14F9A4aba083D18AFEa46";
const CONTRACT_ABI = [
  "function fund() public payable",
  "function withdraw() public",
  "function getAddressToAmountFunded(address funder) public view returns (uint256)",
  "function getOwner() public view returns (address)",
];

export default function SmartFunding() {
  const [status, setStatus] = useState({
    account: "",
    balance: "0",
    isOwner: false,
    contributed: "0",
    isLoading: false,
    error: "",
  });

  const checkIfWalletIsConnected = useCallback(async () => {
    try {
      if (typeof window.ethereum !== "undefined") {
        const accounts = (await window.ethereum.request({
          method: "eth_accounts",
        })) as WalletResponse;

        if (accounts.length > 0) {
          setStatus((prev) => ({ ...prev, account: accounts[0] }));
          await updateContractInfo(accounts[0]);
        }
      }
    } catch (err) {
      console.error("Error checking wallet connection:", err);
      setStatus((prev) => ({
        ...prev,
        error: "Error checking wallet connection",
      }));
    }
  }, []);

  const connectWallet = async () => {
    try {
      const { ethereum } = window;
      if (!ethereum) {
        setStatus((prev) => ({ ...prev, error: "Please install MetaMask!" }));
        return;
      }

      try {
        await ethereum.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: "0xaa36a7" }],
        });
      } catch (err) {
        console.error("Error switching network:", err);
        setStatus((prev) => ({
          ...prev,
          error: "Please switch to Sepolia network in MetaMask",
        }));
        return;
      }

      const accounts = (await ethereum.request({
        method: "eth_requestAccounts",
      })) as WalletResponse;

      setStatus((prev) => ({ ...prev, account: accounts[0] }));
      await updateContractInfo(accounts[0]);
    } catch (err) {
      console.error("Error connecting wallet:", err);
      setStatus((prev) => ({
        ...prev,
        error: "Error connecting wallet",
      }));
    }
  };

  const updateContractInfo = async (account: string) => {
    try {
      const provider = new ethers.BrowserProvider(
        window.ethereum as Eip1193Provider
      );
      const contract = new ethers.Contract(
        CONTRACT_ADDRESS,
        CONTRACT_ABI,
        provider
      );

      const balance = await provider.getBalance(CONTRACT_ADDRESS);
      const owner = await contract.getOwner();
      const contributed = await contract.getAddressToAmountFunded(account);

      setStatus((prev) => ({
        ...prev,
        balance: ethers.formatEther(balance),
        isOwner: owner.toLowerCase() === account.toLowerCase(),
        contributed: ethers.formatEther(contributed),
      }));
    } catch (err) {
      console.error("Error fetching contract info:", err);
      setStatus((prev) => ({ ...prev, error: "Error fetching contract data" }));
    }
  };

  const handleFund = async () => {
    try {
      setStatus((prev) => ({ ...prev, isLoading: true, error: "" }));

      const provider = new ethers.BrowserProvider(
        window.ethereum as Eip1193Provider
      );
      const signer = await provider.getSigner();
      const contract = new ethers.Contract(
        CONTRACT_ADDRESS,
        CONTRACT_ABI,
        signer
      );

      const tx = await contract.fund({
        value: ethers.parseEther("0.1"),
      });

      await tx.wait();
      await updateContractInfo(status.account);
    } catch (err) {
      console.error("Transaction failed:", err);
      setStatus((prev) => ({
        ...prev,
        error: "Transaction failed. Make sure you have enough ETH!",
      }));
    } finally {
      setStatus((prev) => ({ ...prev, isLoading: false }));
    }
  };

  const handleWithdraw = async () => {
    try {
      setStatus((prev) => ({ ...prev, isLoading: true, error: "" }));

      const provider = new ethers.BrowserProvider(
        window.ethereum as Eip1193Provider
      );
      const signer = await provider.getSigner();
      const contract = new ethers.Contract(
        CONTRACT_ADDRESS,
        CONTRACT_ABI,
        signer
      );

      const tx = await contract.withdraw();
      await tx.wait();
      await updateContractInfo(status.account);
    } catch (err) {
      console.error("Withdrawal failed:", err);
      setStatus((prev) => ({
        ...prev,
        error: "Withdrawal failed. Are you the contract owner?",
      }));
    } finally {
      setStatus((prev) => ({ ...prev, isLoading: false }));
    }
  };

  useEffect(() => {
    checkIfWalletIsConnected();

    if (window.ethereum) {
      const handleAccountsChanged = (accounts: WalletResponse) => {
        if (accounts.length > 0) {
          setStatus((prev) => ({ ...prev, account: accounts[0] }));
          updateContractInfo(accounts[0]);
        } else {
          setStatus((prev) => ({
            ...prev,
            account: "",
            balance: "0",
            isOwner: false,
            contributed: "0",
          }));
        }
      };

      window.ethereum?.on("accountsChanged", handleAccountsChanged);

      return () => {
        window.ethereum?.removeListener(
          "accountsChanged",
          handleAccountsChanged
        );
      };
    }
  }, [checkIfWalletIsConnected]);

  return (
    <div className="max-w-2xl mx-auto p-6 bg-white shadow-lg rounded-xl">
      {status.error && (
        <div className="mb-4 bg-red-100 text-red-800 p-4 rounded-lg">
          {status.error}
        </div>
      )}

      {!status.account ? (
        <button
          onClick={connectWallet}
          className="w-full bg-blue-600 text-white p-3 rounded-lg hover:bg-blue-700 transition-all"
        >
          Connect Wallet
        </button>
      ) : (
        <div className="space-y-6">
          <div className="grid grid-cols-2 gap-4">
            <div className="bg-slate-50 p-4 rounded-lg">
              <p className="text-sm text-slate-600">Contract Balance</p>
              <p className="text-2xl font-bold">{status.balance} ETH</p>
            </div>
            <div className="bg-slate-50 p-4 rounded-lg">
              <p className="text-sm text-slate-600">Your Contribution</p>
              <p className="text-2xl font-bold">{status.contributed} ETH</p>
            </div>
          </div>

          <div className="flex flex-col sm:flex-row gap-4">
            <button
              onClick={handleFund}
              disabled={status.isLoading}
              className="flex-1 bg-blue-600 text-white p-3 rounded-lg hover:bg-blue-700 disabled:bg-slate-400 transition-all"
            >
              {status.isLoading ? "Processing..." : "Fund (0.1 ETH)"}
            </button>

            {status.isOwner && (
              <button
                onClick={handleWithdraw}
                disabled={status.isLoading}
                className="flex-1 bg-green-600 text-white p-3 rounded-lg hover:bg-green-700 disabled:bg-slate-400 transition-all"
              >
                {status.isLoading ? "Processing..." : "Withdraw"}
              </button>
            )}
          </div>

          <div className="text-center text-sm text-slate-600">
            Connected: {status.account.slice(0, 6)}...{status.account.slice(-4)}
          </div>
        </div>
      )}
    </div>
  );
}
