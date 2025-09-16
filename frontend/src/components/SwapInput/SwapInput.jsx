// SwapInput.jsx
import React from "react";
import "./SwapInput.css";

const SwapInput = ({
  title,
  placeholder,
  value,
  onChange,
  readOnly = false,
  className = "",
}) => {
  return (
    <div className={`swap-input-container ${className}`}>
      <div className="swap-input-title">{title}</div>
      <input
        type="number"
        className="swap-input-field"
        placeholder={placeholder}
        value={value}
        onChange={onChange}
        readOnly={readOnly}
        min="0"
        step="any"
      />
    </div>
  );
};

export default SwapInput;
