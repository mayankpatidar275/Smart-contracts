// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract LoanApplication {
    // Mapping to store loan details
    // mapping (address => Loan[]) public loans;
    mapping (address => mapping(uint256 => Loan)) public loans;
    mapping (address => uint256) public creditworthiness;
    mapping (address => uint256) public loancounts;
    // Mapping to store interest rates
    mapping (uint256 => mapping (uint256 => uint256)) public interestRates;

    // Struct to define loan details
    struct Loan {
        uint256 loanId;
        uint256 amount;
        uint256 duration;
        uint256 interestRate;
        uint256 interest;
        bool approved;
        bool repaid;
    }

    uint256 private loanCounter = 0;
    uint256 public contractBalance = 1000;

    // Declare events
    event LoanApplied(address indexed borrower, uint256 loanId);
    event LoanApproved(address indexed borrower, uint256 loanId);
    event LoanRepaid(address indexed borrower, uint256 loanId);
    event InterestRateSet(uint256 amount, uint256 duration, uint256 interestRate);

    // function to revert all unknown transactions
    receive () external payable {
        revert("This contract does not accept");
    }
    
    // Generate a unique loan ID
    function generateLoanId(uint256 _amount) internal view returns (uint256) {
        uint256 time = block.timestamp;
        uint256 random = uint256(keccak256(abi.encodePacked(time, msg.sender, _amount)));
        return random;
    }

    // Function to apply for a loan
    function applyForLoan(uint256 _amount, uint256 _duration) public {
        
        // Set default creditworthiness to 50
        if ((creditworthiness[msg.sender] == 0) && (loancounts[msg.sender] == 0)) {
            creditworthiness[msg.sender] = 50;
        }

        require(creditworthiness[msg.sender] >= 50, "Insufficient creditworthiness, you should improve your credit score");

        uint256 interestRate = interestRates[_amount][_duration];

        // Calculate interest
        uint256 interest = _amount * interestRate * _duration / 100;
        
        // Store loan details
        Loan memory newLoan = Loan(generateLoanId(_amount), _amount, _duration, interestRate, interest, false, false);
        loans[msg.sender][generateLoanId(_amount)] = newLoan;
        loancounts[msg.sender]++;

        // Emit event to log loan application
        emit LoanApplied(msg.sender, generateLoanId(_amount));
    }

    // Function to approve a loan
    function approveLoan(address payable _borrower, uint256 _loanId) public {
        // Check if the loan with the specified ID exists for the borrower
        Loan memory loan = loans[_borrower][_loanId];
        require(loan.loanId == _loanId, "No such loan found");
        // Check if loan is not approved
        require(!loan.approved, "Loan already approved");

        // Check if creditworthiness of the borrower is sufficient
        require(creditworthiness[_borrower] >= 50, "Insufficient creditworthiness, you should improve your credit score");

        // Transfer the loan amount to the borrower
        require(contractBalance >= loan.amount, "Sorry ! Insufficient funds in contract, consider reducing the loan amount or try later");
        // Check the success of the transfer
        bool transferSuccessful = _borrower.send(loan.amount);
        require(transferSuccessful, "Transaction failedd");
        contractBalance -= loan.amount;

        // Approve the loan
        loan.approved = true;

        // Emit event to log loan approval
        emit LoanApproved(msg.sender, generateLoanId(loan.amount));

        // improve the creditworthiness
        creditworthiness[_borrower] += 10;
    }


    function repay(address payable _borrower, uint256 _loanId, uint256 _amount) public payable {
        // Check if the loan with the specified ID exists for the borrower
        require(loans[_borrower][_loanId].loanId == _loanId, "Loan not found.");

        // Check if the loan is approved
        require(loans[_borrower][_loanId].approved, "Loan not approved.");

        // Check if the borrower is paying enough to cover the entire loan
        require(_amount >= loans[_borrower][_loanId].amount + loans[_borrower][_loanId].interest, "Amount is insufficient.");

        // Update the amount repaid for the loan
        loans[_borrower][_loanId].amount = 0;
        loans[_borrower][_loanId].repaid = true; // set the loan as repaid
        contractBalance += _amount;
        
        // Emit event to log loan approval
        emit LoanRepaid(msg.sender, generateLoanId(_amount));
    }


    // Function to set interest rates
    function setInterestRate(uint256 _amount, uint256 _duration, uint256 _interestRate) public {
        require(msg.sender == address(this), "Only contract owner can set interest rates.");
        interestRates[_amount][_duration] = _interestRate;
        
        emit InterestRateSet(_amount, _duration, _interestRate);
    }

}
