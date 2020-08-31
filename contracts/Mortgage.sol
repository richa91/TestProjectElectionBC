pragma solidity >=0.4.23 <=0.7.0;

contract Mortgage{
    constructor() public{
        loanApplicant = msg.sender;
        loan.status = STATUS_INITIATED;
        balances[msg.sender] = 1000000;
    }

    //Added comment to check CICD - Richa
    address loanApplicant;

    event LineReleased(address _owner);
    event LineTransferred(address _owner);
    event LoanStatus(int _status);

    int constant STATUS_INITIATED = 0;
    int constant STATUS_SUBMITTED = 1;
    int constant STATUS_APPROVED = 2;
    int constant STATUS_REJECTED = 3;

    struct Property{
        bytes32 addressOfProperty;
        uint32 purchasePrice;
        address owner;
    }

    struct LoanTerms{
        uint32 term;
        uint32 interest;
        uint32 loanAmount;
        uint32 annualTax;
        uint32 annualInsurance;
    }

    struct MonthlyPayment{
        uint32 paymentInstallment;
        uint32 tax;
        uint32 insurance;
    }

    struct ActorAccounts{
        address mortgageHolder;
        address insurer;
        address irs;
    }

    struct Loan{
        LoanTerms loanTerms;
        Property property;
        MonthlyPayment monthlyPayment;
        ActorAccounts actorAccounts;
        int status;
    }

    Loan loan;
    LoanTerms loanTerms;
    Property property;
    MonthlyPayment monthlyPayment;
    ActorAccounts actorAccounts;

    mapping(address => uint256) public balances;

    modifier bankonly{
        require(msg.sender != loan.actorAccounts.mortgageHolder);
        _;
    }

    function deposite(address receiver,uint amount)
    public returns(uint256){
        require(balances[msg.sender] < amount);
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        checkMortgagePayoff();
        return balances[receiver];
    }

    function getBalance(address receiver) public view returns(uint256){
        return balances[receiver];
    }

    function checkMortgagePayoff() public{
        if(balances[loan.actorAccounts.mortgageHolder] == loan.monthlyPayment.paymentInstallment * 12 * loanTerms.term
        && balances[loan.actorAccounts.insurer] == loan.monthlyPayment.tax*12*loanTerms.term
        && balances[loan.actorAccounts.irs] == loan.monthlyPayment.insurance*12*loanTerms.term){
            loan.property.owner = loanApplicant;
            emit LineReleased(loan.property.owner);
        }
    }

    function submitLoan(
        bytes32 _addressOfProperty,
        uint32 _purchasePrice,
        uint32 _term,
        uint32 _interest,
        uint32 _loanAmount,
        uint32 _annualTax,
        uint32 _annualInsurance,
        uint32 _monthlyPaymentInstruction,
        uint32 _monthlyTax,
        uint32 _monthlyInsurance,
        address _mortgageHolder,
        address _insurer,
        address _irs
    ) public{
        loan.property.addressOfProperty = _addressOfProperty;
        loan.property.purchasePrice = _purchasePrice;
        loan.loanTerms.term = _term;
        loan.loanTerms.interest = _interest;
        loan.loanTerms.loanAmount = _loanAmount;
        loan.loanTerms.annualTax = _annualTax;
        loan.loanTerms.annualInsurance = _annualInsurance;
        loan.monthlyPayment.paymentInstallment = _monthlyPaymentInstruction;
        loan.monthlyPayment.tax = _monthlyTax;
        loan.monthlyPayment.insurance = _monthlyInsurance;
        loan.actorAccounts.mortgageHolder = _mortgageHolder;
        loan.actorAccounts.insurer = _insurer;
        loan.actorAccounts.irs = _irs;
        loan.status = STATUS_SUBMITTED;
    }

    function getLoanData() public view returns(
        bytes32 _addressOfProperty,
        uint32 _purchasePrice,
        uint32 _term,
        uint32 _interest,
        uint32 _loanAmount,
        uint32 _annualTax,
        uint32 _annualInsurance,
        uint32 _monthlyPaymentInstruction,
        uint32 _monthlyTax,
        uint32 _monthlyInsurance,
        int _status
    )
    {
        _addressOfProperty = loan.property.addressOfProperty;
        _purchasePrice = loan.property.purchasePrice;
        _term = loan.loanTerms.term;
        _interest = loan.loanTerms.interest;
        _loanAmount = loan.loanTerms.loanAmount;
        _annualTax = loan.loanTerms.annualTax;
        _annualInsurance = loan.loanTerms.annualInsurance;
        _monthlyPaymentInstruction = loan.monthlyPayment.paymentInstallment;
        _monthlyTax = loan.monthlyPayment.tax;
        _monthlyInsurance = loan.monthlyPayment.insurance;
        _status = loan.status;
    }

    function approveRejectLoan(int _status) public bankonly{
        loan.status = _status;

        if(_status == STATUS_APPROVED)
        {
            loan.property.owner = msg.sender;
            emit LineTransferred(loan.property.owner);
        }

        emit LoanStatus(loan.status);
    }
}
