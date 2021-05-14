pragma solidity ^0.4.19;

contract SmartTreeFunding {
    
    // Push Blockchain Event to Dapp
    event NewTreeFund(uint treeId, string name, uint duration, uint goalAmount);
    
    struct Investor {
        address addr;
        uint amount;
        
    }
    
    struct TreeFund {
        string name;
    	uint numInvestors;	// ������ ��
    	
    	uint deadline;		// ������ (UnixTime)
    	string status;		// ���Ȱ�� �������ͽ�
    	bool ended;			// ��� ���Ῡ��
    	
    	uint goalAmount;	// ��ǥ��
    	uint totalAmount;	// �� ���ھ�
    	
    }
    
    
    TreeFund[] public funds;

    mapping (uint => address) public fundsToOwner;          // uint: fundId, address: Owner
    mapping (uint => Investor[]) public fundsToInvestors;   // uint: fundId, Investor: Investor info array
    
    
    function _createTreeFund(string _name, uint _duration, uint _goalAmount) view private returns (TreeFund) {
		// Set funds time limitation based on Unixtime
		uint deadline = now + _duration;
        
		uint goalAmount = _goalAmount;
		string memory status = "Funding";
		bool ended = false;

		uint numInvestors = 0;
		uint totalAmount = 0;
		
		TreeFund memory newFund = TreeFund(_name, numInvestors, deadline, status, ended, goalAmount, totalAmount);
		return newFund;
		
    }
    
    function createSmartTreeFunding(string _name, uint _duration, uint _goalAmount) public {
        TreeFund memory newFund = _createTreeFund(_name, _duration, _goalAmount);
        uint fundId = funds.push(newFund) - 1;
        
        fundsToOwner[fundId] = msg.sender;
        NewTreeFund(fundId, _name, _duration, _goalAmount);
        
    }

    // edit function definition below
    function SmartTreeFunding(string _name, uint _duration, uint _goalAmount) public {
        createSmartTreeFunding(_name, _duration, _goalAmount);
       
    }
    
    // Selct Uinque Fund and make transaction
	function fund(uint _fundId) public payable {
		// Check whether (fundId) is finished or not
		require(!funds[_fundId].ended);
		
        Investor memory newInvestor = Investor(msg.sender, msg.value);
        fundsToInvestors[_fundId].push(newInvestor);
        
        funds[_fundId].numInvestors++;
        funds[_fundId].totalAmount += msg.value;
        
	}
	
	function getFundsCount() view public returns (uint) {
	    return funds.length;
	    
	}
	
	function checkGoalReached(uint _fundId) public {		
		// Only for fund owner
		require(msg.sender == fundsToOwner[_fundId]);
		
		// ����� �����ٸ� ó�� �ߴ�
		require(!funds[_fundId].ended);
		
		// ������ ������ �ʾҴٸ� ó�� �ߴ�
		require(now >= funds[_fundId].deadline);
		
		if(funds[_fundId].totalAmount >= funds[_fundId].goalAmount) {	// ��� ������ ���
			funds[_fundId].status = "Campaign Succeeded";
			funds[_fundId].ended = true;
			// ��Ʈ��Ʈ �����ڿ��� ��Ʈ��Ʈ�� �ִ� ��� �̴��� �۱�
			if(!fundsToOwner[_fundId].send(this.balance)) {
				revert();
			}
		} else {	// ��� ������ ���
			funds[_fundId].status = "Campaign Failed";
			funds[_fundId].ended = true;
			
			// �� �����ڿ��� ���ڱ��� ������
			for (uint i=0; i < funds[_fundId].numInvestors; i++) {
			    Investor memory currentInvestor = fundsToInvestors[_fundId][i];
				if(!currentInvestor.addr.send(currentInvestor.amount)) {
				    revert();
				}
				
			}
		}
	}

}
