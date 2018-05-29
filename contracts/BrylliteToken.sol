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
    uint8   public  constant decimals = 18;

    enum stage {Initial,First,Second}

    // mapping (address => bool) public frozenAccount;
    
     // new feature, Lee
    mapping(address => uint) approvedInvestorListWithDate;

    // struct _DateTime {
    //         uint16 year;
    //         uint8 month;
    //         uint8 day;
    //         uint8 hour;
    //         uint8 minute;
    //         uint8 second;
    //         uint8 weekday;
    // }

    // uint constant DAY_IN_SECONDS = 86400;
    // uint constant YEAR_IN_SECONDS = 31536000;
    // uint constant LEAP_YEAR_IN_SECONDS = 31622400;

    // uint constant HOUR_IN_SECONDS = 3600;
    // uint constant MINUTE_IN_SECONDS = 60;
    // uint16 constant ORIGIN_YEAR = 1970;


    // uint startDate = 1514764800; // 2018-01-01 00:00:00
    // uint endDate = 1518220800; // 2018-02-10 00:00:00

    // uint diff = (endDate - startDate) / 60 / 60 / 24; // 40 days 

    function BrylliteToken( address _admin, uint _totalTokenAmount ) 
    {
        admin = _admin;

        totalSupply = _totalTokenAmount;
        balances[msg.sender] = _totalTokenAmount;
        Transfer(address(0x0), msg.sender, _totalTokenAmount);
    }


   // modifier afterDeadline() { if (now >= deadline) _; }
    // Freeze funds.
    // event FrozenFunds(address target, bool frozen);
    event LockFundsReleaseTime(address target, uint time);

    // Owner can set any account into freeze state.
    // It is helpful in case if account holder has lost his key and he want administrator to freeze account until account key is covered.
    // @ target : account address
    // @ state : state of account 
    // function freezeAccount(address target, bool freeze) onlyOwner {
    //     frozenAccount[target] = freeze;
    //     FrozenFunds(target, freeze);
    // }

    //  function totalSupply() constant returns (uint supply) {
    //     return totalSupply;
    // }

    function getTime() internal constant returns (uint) {
        return now;
    }

    function isUnlocked() internal returns (bool) {
        return getTime() >= getLockFundsReleaseTime(msg.sender);
    }

    modifier validDestination( address to )
    {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    modifier onlyWhenUnlocked()
    {
        // require(!frozenAccount[msg.sender]);
        require(isUnlocked());            
        _;
    }

    function transfer(address _to, uint _value) onlyWhenUnlocked validDestination(_to) returns (bool) 
    {
        // require(!frozenAccount[msg.sender]);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) onlyWhenUnlocked validDestination(_to) returns (bool) 
    {
        // require(!frozenAccount[_from]);
        // require(!frozenAccount[_to]);
        require(getTime() >= getLockFundsReleaseTime(_from));
        return super.transferFrom(_from, _to, _value);
    }

    // function getLockedFundsReleaseTime() internal constant returns (uint x)
    // {
    //     return approvedInvestorListWithDate[msg.sender];
    // }

    function getLockFundsReleaseTime(address _addr) constant returns(uint) 
    {
        // require(msg.sender == admin || msg.sender == owner);
        LockFundsReleaseTime(_addr, approvedInvestorListWithDate[_addr]);
        return approvedInvestorListWithDate[_addr];
    }

    function addInvestor(address[] newInvestorList, uint releaseTime) onlyOwner public 
    {
        if(releaseTime > getTime())
        {
            for (uint i = 0; i < newInvestorList.length; i++)
            {
                approvedInvestorListWithDate[newInvestorList[i]] = releaseTime;
            }
        }
    }

    function removeInvestor(address[] investorList) onlyOwner public 
    {
        for (uint i = 0; i < investorList.length; i++)
        {
            approvedInvestorListWithDate[investorList[i]] = 0;
            delete(approvedInvestorListWithDate[investorList[i]]);
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


    function () public payable 
    {
        revert();
    }
}