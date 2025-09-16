import React from "react";
import "./Footer.css";

const Footer = () => {
  const handleTwitterClick = () => {
    // Add Twitter/X profile link here
    window.open("https://x.com/atharvamuley", "_blank");
  };

  const handleEmailClick = () => {
    // Add email contact functionality here
    window.open("mailto:theatharvamuley@gmail.com", "_blank");
  };

  return (
    <footer className="footer">
      <div className="footer-container">
        <div className="footer-left">
          <span className="contact-text">Contact -</span>
          <div className="social-icons">
            <button
              className="social-btn twitter-btn"
              onClick={handleTwitterClick}
              aria-label="Twitter/X"
            >
              <svg
                className="social-icon"
                viewBox="0 0 24 24"
                fill="currentColor"
              >
                <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
              </svg>
            </button>

            <button
              className="social-btn email-btn"
              onClick={handleEmailClick}
              aria-label="Email"
            >
              <svg
                className="social-icon"
                viewBox="0 0 24 24"
                fill="currentColor"
              >
                <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.89 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z" />
              </svg>
            </button>
          </div>
        </div>

        <div className="footer-right">
          <span className="built-by-text">Built By - </span>
          <span className="developer-name">atharva muley</span>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
