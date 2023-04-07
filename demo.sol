// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract SmallLakeProject {
    // State variables
    address public gramPanchayat;
    address public bdo;
    address public engineers;
    address public contractor;

    uint256 public requiredFunds;
    uint256 public allocatedFunds;

    //bdo variable
    bool public projectApproved;
    bool public receivedProposal;
    bool public contractorAllocated;

    //contractor variable
    uint256 public fundtostart;
    bool public completefullproject;
    bool public projectCompleted;
    bool public workstarted;

    //engineer variable
    bool public validationReceived;
    uint256 public estimationAmount;

    //status variable
    string status = "Project proposal not received";
    
    // Events
    event FundsAllocated(uint amount);
    event ValidationReceived();
    event ProjectApproved();
    event ProjectCompleted();
    
    // Constructor
    constructor() {
        bdo = msg.sender;
    }
    
    // Modifier to restrict access to the BDO
    modifier onlyBDO() {
        require(msg.sender == bdo, "Only BDO can call this function");
        _;
    }
    
    // Modifier to restrict access to the engineers
    modifier onlyEngineers() {
        require(msg.sender == engineers, "Only engineers can call this function");
        _;
    }
    
    // Modifier to restrict access to the contractor
    modifier onlyContractor() {
        require(msg.sender == contractor, "Only contractor can call this function");
        _;
    }

    function getter() view public returns (uint256) {
        return allocatedFunds;
    }

    function getest() view public returns (uint256) {
        return estimationAmount;
    }
    
    // Function to receive proposal from gram panchayat
    function receiveProposal(address _gramPanchayat, bool rec_proposal) external onlyBDO {
        require(rec_proposal == true, "Proposal has not been received yet");
        receivedProposal = rec_proposal;
        gramPanchayat = _gramPanchayat;
        status = "Project Proposal Received";
    }
    
    // Function to assign verification task to engineers
    function assignVerificationTask(address _engineers) external onlyBDO {
        require(receivedProposal == true, "Proposal has not been received yet");
        engineers = _engineers;
        status = "Project in verification process";
    }
    
    // Function for engineers to verify the need of the project
    function verifyProject(bool _needVerification) external onlyEngineers {
        require(_needVerification == true, "Project does not require verification");
        validationReceived = true;
        emit ValidationReceived();
    }
    
    // Function to approve the project
    function approveProject(bool _approveProject) external onlyBDO {
        require(validationReceived == true, "Project has not been verified yet");
        require(_approveProject == true, "Project has not been approved");
        projectApproved = true;
        status = "Project has been approved";
        emit ProjectApproved();
    }

    // Function for engineers to calculate estimation amount
    function setestimationamt(uint256 _estimationamt) external onlyEngineers {
        require(projectApproved == true, "Project has not been approved");
        
        estimationAmount = _estimationamt;
    }
    
    
    // Function to assign the contractor
    function assignContractor(address _contractor) external onlyBDO {
        require(projectApproved == true, "Project has not been approved");
        contractorAllocated = true;
        contractor = _contractor;
    }

    // Function to allocate initial amount to the contractor
    function initialamt() external onlyBDO payable{
        require(projectApproved == true && contractorAllocated == true, "Project has not been approved yet and contractor is not allocated");
        require(msg.value > 0, "Not enough funds available");
        payable(contractor).transfer(msg.value);


        allocatedFunds += msg.value;
    } 
    
    // Function for contractor to start working
    function startWorking() external onlyContractor {
        require(projectApproved == true, "Project has not been approved yet");
        require(allocatedFunds > 0, "Funds have not been allocated yet");
        status = "Project is in working process";
        workstarted = true;
       
    }

    // Function to check project completed by the engineers
    function updateProgress() external onlyEngineers {
        require(workstarted == true, "Project has not started yet");
        completefullproject = true;
    }

    // Function for contractor to request final installment
    function requestFinalInstallment() external onlyContractor {
        require(projectApproved == true, "Project has not been approved yet");
        require(completefullproject == true, "Funds have not been fully allocated yet");
        projectCompleted = true;
        status = "Project Completed Successfully";
        emit ProjectCompleted();
        
    }
    
    // Function for BDO to allocate final funds
    function allocateFunds() external onlyBDO payable{
        require(projectApproved == true && contractorAllocated == true, "Project has not been approved yet");
        require(projectCompleted == true, "Project has not been completed yet");
        // require(msg.value == estimationAmount - allocatedFunds, "Not enough funds available");
        payable(contractor).transfer(msg.value);
        allocatedFunds += msg.value;
        emit FundsAllocated(msg.value);
    }

    //function to get the address of contractor
    function getContractor() public view returns (address) {
        require(projectCompleted == true, "Project has not been completed yet");
        return contractor;
    }

    // function to get address of the BDO
    function getBDO() public view returns (address) {
        require(receivedProposal == true, "Project has not been completed yet");
        return bdo;
    }
    
    // function to get the allocated funds
    function getAllocatedFunds() public view returns (uint256) {
        require(projectCompleted == true, "Project has not been completed yet");
        return allocatedFunds;
    }
    
    function getStatus() public view returns (string memory) {
        return status;
    }
    
}


