// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract LoanApplication {
    // Mapping to store loan details
    mapping (address => Loan[]) public loans;
    mapping (address => uint256) public creditworthiness;
    
    // Struct to define loan details
    struct Loan {
        uint256 loanId;
        uint256 amount;
        uint256 duration;
        uint256 interestRate;
        uint256 interest;
        bool approved;
    }

    uint256 private loanCounter = 0;
    uint256 public contractBalance = 1000;

    // Function to apply for a loan
    function applyForLoan(uint256 _amount, uint256 _duration) public {
        
        // Set default creditworthiness to 50
        if ((creditworthiness[msg.sender] == 0) && (loans[msg.sender].length == 0)) {
            creditworthiness[msg.sender] = 50;
        }

        require(creditworthiness[msg.sender] >= 50, "Insufficient creditworthiness.");

        // Decide interest rate based on loan amount and duration
        uint256 interestRate;
        if (_amount <= 1000 && _duration <= 12) {
            interestRate = 5;
        } else if (_amount <= 10000 && _duration <= 24) {
            interestRate = 7;
        } else {
            interestRate = 10;
        }

        // Calculate interest
        uint256 interest = _amount * interestRate * _duration / 100;

        // Store loan details
        Loan memory newLoan = Loan(loanCounter, _amount, _duration, interestRate, interest, false);
        loans[msg.sender].push(newLoan);
        loanCounter++;
    }

    // Function to approve a loan
    function approveLoan(address payable _borrower, uint256 _loanId) public {
        // Check if the loan with the specified ID exists for the borrower
        require(loans[_borrower][_loanId].loanId == _loanId, "Loan not found.");
        // Check if loan is not approved
        require(!loans[_borrower][_loanId].approved, "Loan already approved.");

        // Check if creditworthiness of the borrower is sufficient
        require(creditworthiness[_borrower] >= 50, "Insufficient creditworthiness.");

        // Transfer the loan amount to the borrower
        require(contractBalance >= loans[_borrower][_loanId].amount, "Insufficient funds in contract.");
        // require(_borrower.send(loans[_borrower][_loanId].amount), "Transfer failed.");
        contractBalance -= loans[_borrower][_loanId].amount;

        // Approve the loan
        loans[_borrower][_loanId].approved = true;

        // improve the creditworthiness
        creditworthiness[_borrower] += 10;
    }

    function repay(address payable _borrower, uint256 _loanId, uint256 _amount) public payable{
        // Check if the loan with the specified ID exists for the borrower
        require(loans[_borrower][_loanId].loanId == _loanId, "Loan not found.");

        // Check if the loan is approved
        require(loans[_borrower][_loanId].approved, "Loan not approved.");

        // Check if the borrower is paying enough to cover the entire loan
        require(_amount >= loans[_borrower][_loanId].amount + loans[_borrower][_loanId].interest, "Amount is insufficient.");

        // Update the amount repaid for the loan
        loans[_borrower][_loanId].amount = 0;
        contractBalance += _amount;
       
}

}