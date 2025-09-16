// Complete SwapContainer.jsx using the new SwapButton component
import React, { useState } from "react";
import SwapInput from "../SwapInput/SwapInput";
import SwapButton from "../SwapButton/SwapButton";
import "./SwapContainer.css";

const SwapContainer = () => {
  const [sellAmount, setSellAmount] = useState("");
  const [receiveAmount, setReceiveAmount] = useState("");

  // Configuration for the swap
  const swapConfig = {
    feePercentage: 1, // 1% fee
    exchangeRate: 0.99, // USDC to USDT rate
    minSwapAmount: 0.01,
    maxSwapAmount: 1000000,
  };

  // Handle input change for sell amount
  const handleSellAmountChange = (e) => {
    const value = e.target.value;
    setSellAmount(value);
  };

  // Handle calculation updates from SwapButton
  const handleCalculationUpdate = (calculatedAmount) => {
    setReceiveAmount(calculatedAmount);
  };

  // Handle swap start (called when user clicks swap and validation passes)
  const handleSwapStart = async (swapDetails) => {
    console.log("Swap started with details:", swapDetails);

    // You can add pre-swap logic here:
    // - Show confirmation modal
    // - Check wallet balance
    // - Validate blockchain connection
    // - etc.
  };

  // Handle swap completion (success or failure)
  const handleSwapComplete = async (result) => {
    console.log("Swap completed:", result);

    if (result.success) {
      console.log("Transaction Hash:", result.transactionHash);
      console.log("Swap Details:", result.details);

      // Success actions:
      // - Show success notification
      // - Update wallet balance
      // - Clear form
      // - Add to transaction history
      // - etc.

      // Clear the form after successful swap
      setSellAmount("");
      setReceiveAmount("");
    } else {
      console.error("Swap failed:", result.error);

      // Error handling:
      // - Show error notification
      // - Log error for debugging
      // - Suggest retry or alternative
      // - etc.
    }
  };

  return (
    <div className="swap-container">
      <SwapInput
        title="SELL USDC"
        placeholder="ENTER AMOUNT"
        value={sellAmount}
        onChange={handleSellAmountChange}
        readOnly={false}
      />

      <SwapInput
        title="GET USDT"
        placeholder="YOU RECEIVE"
        value={receiveAmount}
        onChange={() => {}} // No onChange needed for read-only
        readOnly={true}
      />

      <SwapButton
        sellAmount={sellAmount}
        receiveAmount={receiveAmount}
        onCalculationUpdate={handleCalculationUpdate}
        onSwapStart={handleSwapStart}
        onSwapComplete={handleSwapComplete}
        feePercentage={swapConfig.feePercentage}
        exchangeRate={swapConfig.exchangeRate}
        minSwapAmount={swapConfig.minSwapAmount}
        maxSwapAmount={swapConfig.maxSwapAmount}
        disabled={false}
      />
    </div>
  );
};

export default SwapContainer;
