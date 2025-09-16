// SwapButton.jsx
import React, { useState } from "react";
import "./SwapButton.css";

const SwapButton = ({
  sellAmount,
  receiveAmount,
  onSwapComplete,
  onSwapStart,
  onCalculationUpdate,
  disabled = false,
  feePercentage = 1, // Default 1% fee
  exchangeRate = 0.99, // Default USDC to USDT rate
  minSwapAmount = 0.01,
  maxSwapAmount = 1000000,
}) => {
  const [isLoading, setIsLoading] = useState(false);
  const [swapStatus, setSwapStatus] = useState(""); // 'success', 'error', or ''

  // Calculate the receive amount based on sell amount
  const calculateReceiveAmount = (sellValue) => {
    if (!sellValue || isNaN(sellValue) || parseFloat(sellValue) <= 0) {
      return "";
    }

    const sellNum = parseFloat(sellValue);

    // Apply exchange rate and fee
    const afterFee = sellNum * (1 - feePercentage / 100);
    const finalAmount = afterFee * exchangeRate;

    return finalAmount.toFixed(6); // 6 decimal places for precision
  };

  // Validate swap amounts
  const validateSwap = () => {
    const sellNum = parseFloat(sellAmount);

    if (!sellAmount || isNaN(sellNum)) {
      return { isValid: false, error: "Please enter a valid amount" };
    }

    if (sellNum < minSwapAmount) {
      return {
        isValid: false,
        error: `Minimum swap amount is ${minSwapAmount}`,
      };
    }

    if (sellNum > maxSwapAmount) {
      return {
        isValid: false,
        error: `Maximum swap amount is ${maxSwapAmount}`,
      };
    }

    if (sellNum <= 0) {
      return { isValid: false, error: "Amount must be greater than 0" };
    }

    return { isValid: true, error: null };
  };

  // Get swap details for display
  const getSwapDetails = () => {
    const sellNum = parseFloat(sellAmount) || 0;
    const receiveNum = parseFloat(receiveAmount) || 0;
    const feeAmount = sellNum * (feePercentage / 100);

    return {
      sellAmount: sellNum,
      receiveAmount: receiveNum,
      feeAmount: feeAmount.toFixed(6),
      feePercentage,
      exchangeRate,
      effectiveRate: receiveNum / sellNum || 0,
    };
  };

  // Handle swap button click
  const handleSwap = async () => {
    const validation = validateSwap();

    if (!validation.isValid) {
      alert(validation.error);
      return;
    }

    setIsLoading(true);
    setSwapStatus("");

    try {
      // Call onSwapStart callback if provided
      if (onSwapStart) {
        await onSwapStart(getSwapDetails());
      }

      // Simulate API call (replace with your actual swap logic)
      await simulateSwapTransaction();

      setSwapStatus("success");

      // Call onSwapComplete callback if provided
      if (onSwapComplete) {
        await onSwapComplete({
          success: true,
          details: getSwapDetails(),
          transactionHash: generateMockTxHash(),
        });
      }
    } catch (error) {
      setSwapStatus("error");
      console.error("Swap failed:", error);

      if (onSwapComplete) {
        await onSwapComplete({
          success: false,
          error: error.message,
          details: getSwapDetails(),
        });
      }
    } finally {
      setIsLoading(false);

      // Reset status after 3 seconds
      setTimeout(() => {
        setSwapStatus("");
      }, 3000);
    }
  };

  // Simulate blockchain transaction (replace with real implementation)
  const simulateSwapTransaction = () => {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        // Simulate 90% success rate
        if (Math.random() > 0.1) {
          resolve();
        } else {
          reject(new Error("Transaction failed"));
        }
      }, 2000); // Simulate 2 second transaction time
    });
  };

  // Generate mock transaction hash
  const generateMockTxHash = () => {
    return "0x" + Math.random().toString(16).substring(2, 66);
  };

  // Update calculation when component mounts or dependencies change
  React.useEffect(() => {
    const calculatedAmount = calculateReceiveAmount(sellAmount);
    if (onCalculationUpdate && calculatedAmount !== receiveAmount) {
      onCalculationUpdate(calculatedAmount);
    }
  }, [sellAmount, feePercentage, exchangeRate]);

  // Determine button text and state
  const getButtonText = () => {
    if (isLoading) return "SWAPPING...";
    if (swapStatus === "success") return "SUCCESS!";
    if (swapStatus === "error") return "FAILED - TRY AGAIN";
    return "SWAP";
  };

  const getButtonClass = () => {
    let className = "swap-button";
    if (isLoading) className += " loading";
    if (swapStatus === "success") className += " success";
    if (swapStatus === "error") className += " error";
    if (disabled || !sellAmount || parseFloat(sellAmount) <= 0)
      className += " disabled";
    return className;
  };

  const isButtonDisabled =
    disabled || isLoading || !sellAmount || parseFloat(sellAmount) <= 0;

  return (
    <div className="swap-button-container">
      {sellAmount && receiveAmount && (
        <div className="swap-info">
          <div className="swap-rate">
            Rate: 1 USDC ={" "}
            {(parseFloat(receiveAmount) / parseFloat(sellAmount)).toFixed(4)}{" "}
            USDT
          </div>
          <div className="swap-fee">
            Fee: {feePercentage}% (
            {((parseFloat(sellAmount) * feePercentage) / 100).toFixed(4)} USDC)
          </div>
        </div>
      )}

      <button
        className={getButtonClass()}
        onClick={handleSwap}
        disabled={isButtonDisabled}
      >
        {isLoading && <div className="loading-spinner"></div>}
        {getButtonText()}
      </button>

      {swapStatus === "success" && (
        <div className="swap-success-message">Swap completed successfully!</div>
      )}

      {swapStatus === "error" && (
        <div className="swap-error-message">Swap failed. Please try again.</div>
      )}
    </div>
  );
};

export default SwapButton;
