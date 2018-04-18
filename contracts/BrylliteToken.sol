pragma solidity ^0.4.18;
import './zeppelin/token/PausableToken.sol';

// Pause States
// There are two flags, pausedPublic and pausedOwnerAdmin.
//
// Initial Stage, pausedPublic is true, pausedOwnerAdmin is false. 
// -> only the owner and admin can transfer tokens.

// Second Stage : both are false
// -> everyone can transfer their own tokens.

// third stage (lock up): both are true
// -> no token transfer would be allowed.

contract BrylliteToken is PausableToken {

    string  public  constant name = "Bryllite";
    string  public  constant symbol = "BRC";
    uint8   public  constant decimals = 8;

    enum stage {Initial,First,Second}

    mapping (address => bool) public frozenAccount;
    
    uint    public  saleStartTime;
    uint    public  date_unlockApprovedInvestor_01;
    uint    public  date_unlockApprovedInvestor_02;

    // List of approved investors
    mapping(address => bool) approvedInvestorList_01;
    mapping(address => bool) approvedInvestorList_02;


    function BrylliteToken( address _admin, uint _totalTokenAmount ) 
    {
        admin = _admin;

        totalSupply = _totalTokenAmount;
        balances[msg.sender] = _totalTokenAmount;
        Transfer(address(0x0), msg.sender, _totalTokenAmount);
    }


   // modifier afterDeadline() { if (now >= deadline) _; }
    // Freeze funds.
    event FrozenFunds(address target, bool frozen);

    // Owner can set any account into freeze state.
    // It is helpful in case if account holder has lost his key and he want administrator to freeze account until account key is covered.
    // @ target : account address
    // @ state : state of account 
    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    modifier validDestination( address to )
    {
        require(to != address(0x0));
        require(to != address(this));
        require(!frozenAccount[msg.sender]);
        if(getStage() == stage.Initial) 
        { 
            require(!approvedInvestorList_01[msg.sender]);
            require(!approvedInvestorList_02[msg.sender]);
        }
        else if(getStage() == stage.First) 
        { 
            require(!approvedInvestorList_02[msg.sender]);
        }
        _;
    }

    modifier validInvestor01() {
        require(approvedInvestorList_01[msg.sender]);
        _;
    }

    modifier validInvestor02() {
        require(approvedInvestorList_02[msg.sender]);
        _;
    }

    function getStage() internal returns (stage) 
    {
        //stage ret = stage.Free;
        stage ret = stage.Initial;
        if(now >= date_unlockApprovedInvestor_01)
        {
            ret = stage.First;
        }
        if(now >= date_unlockApprovedInvestor_02)
        {
            ret = stage.Second;
        }
        return ret;
    }
    
    function transfer(address _to, uint _value) validDestination(_to) returns (bool) 
    {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) validDestination(_to) returns (bool) 
    {
        return super.transferFrom(_from, _to, _value);
    }

    function setUnlockTime(uint _type, uint _unlockTime) onlyOwner
    {
        if(_type == 1)
        {
            date_unlockApprovedInvestor_01 = _unlockTime;
        } 
        else 
        {
            date_unlockApprovedInvestor_02 = _unlockTime;
        }
    }

    /// @dev Adds list of new investors to the investors list and approve all
    /// @param _type investor type 
    /// @param newInvestorList Array of new investors addresses to be added
    function addInvestorList(uint _type, address[] newInvestorList) onlyOwner public 
    {
        for (uint i = 0; i < newInvestorList.length; i++){
            if(_type == 1)
            {
                approvedInvestorList_01[newInvestorList[i]] = true;
            } 
            else
            {
                approvedInvestorList_02[newInvestorList[i]] = true;
            } 
        }
    }

    // /// @dev check address is approved investor
    // /// @param _addr address
    // function isApprovedInvestor(address _addr) onlyOwner public constant returns (bool) {
    //     return approvedInvestorList[_addr];
    // }

    /// @dev Removes list of investors from list
    /// @param _type investor type 
    /// @param investorList Array of addresses of investors to be removed
    function removeInvestorList(uint _type, address[] investorList) onlyOwner public {
        for (uint i = 0; i < investorList.length; i++){
            if(_type == 1)
            {
                approvedInvestorList_01[investorList[i]] = false;
            } 
            else
            {
                approvedInvestorList_02[investorList[i]] = false;
            } 
        }
    }

    event Burn(address indexed _burner, uint _value);

    function burn(uint _value) returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        Transfer(msg.sender, address(0x0), _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) returns (bool) 
    {
        assert( transferFrom( _from, msg.sender, _value ) );
        return burn(_value);
    }

    function emergencyERC20Drain( ERC20 token, uint amount ) onlyOwner {
        token.transfer( owner, amount );
    }

    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);

    function changeAdmin(address newAdmin) onlyOwner {
        AdminTransferred(admin, newAdmin);
        admin = newAdmin;
    }
}