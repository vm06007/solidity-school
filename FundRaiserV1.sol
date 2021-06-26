// SPDX-License-Identifier: -- 💰️ --

pragma solidity ^0.8.0;

//do you need to have the contract you are interfacing with in the same folder or you can interface with any contract? What if contracts are the same name? 
interface ITokenContract {

    function transfer(
        address _to,
        uint256 _value
    )
        external
        returns
    (
        bool success
    );
}

contract WiseFundRaiser {

    address public immutable FUND_OWNER;

    ITokenContract public immutable WISE_TOKEN;

    uint256 public immutable THRESHOLD;
    uint256 public immutable TIMESTAMP;

    uint256 public totalFunded;

    mapping(address => uint256) balanceMap;
    
    uint256 internal callCounter; 
    bool hasBeenClaimed; 

    event Claim (
        address indexed fundOwner, 
        uint256 totalFunded 
    ); 

    event Refund (
        address indexed refundAddress,
        uint256 amount
    );

    event Fund (
        address indexed funder,
        uint256 tokenAmount,
        uint256 refundAmount
        //question
    );

    event Fundraiser (
        address indexed fundOwner,
         uint256 amount, 
        uint256 timestamp
    );

    constructor(
        address _fundOwner,
        address _wiseToken,
        uint256 _tokenAmount,
        uint256 _timeAmount
    )
        payable
    {
        WISE_TOKEN = ITokenContract(
            _wiseToken
        );

        FUND_OWNER = _fundOwner;
        THRESHOLD = _tokenAmount;
        TIMESTAMP = block.timestamp + _timeAmount;

        // events
        emit Fundraiser (
            _fundOwner,
            _tokenAmount,
            _timeAmount
        );
    }

    function fundTokens(
        uint256 _tokenAmount
    )
        external
    {
        /* require(
            totalFunded < THRESHOLD,
            'WiseFundRaiser: invalid amount'
        );*/

        require(
            block.timestamp < TIMESTAMP,
            'WiseFundRaiser: closed'
        );
        
        uint256 refundAmount;
        uint256 tokenAmount = _tokenAmount;

        //how are we declaring this conditional statement if there is no value of total funded. I don't see anywhere where we are calculating a value for total funded.

        if (totalFunded + _tokenAmount > THRESHOLD) {

            uint256 requiredAmount = THRESHOLD - totalFunded;
            refundAmount = _tokenAmount - requiredAmount;

            tokenAmount = requiredAmount;

            _refundTokens(
                msg.sender,
                refundAmount
            );
        }

        totalFunded =
        totalFunded + tokenAmount;

        balanceMap[msg.sender] =
        balanceMap[msg.sender] + tokenAmount;

        // emit
        emit Fund(
            msg.sender,
            tokenAmount,
            refundAmount
        );
    }

    function refundTokens()
        external
    {
        require(
            block.timestamp > TIMESTAMP,
            'WiseFundRaiser: not closed yet'
        );

        require(
            totalFunded < THRESHOLD,
            'WiseFundRaiser: funds raised'
        );

        uint256 refundAmount = balanceMap[msg.sender];
        balanceMap[msg.sender] = 0;

        _refundTokens(
            msg.sender,
            refundAmount
        );

        emit Refund (
            msg.sender,
            refundAmount
        );
    }

    function claimToken()
        external
    {
        require(
            block.timestamp > TIMESTAMP,
            'WiseFundRaiser: not closed yet'
        );

        require(
            totalFunded >= THRESHOLD,
            'WiseFundRaiser: funds not raised'
        );
    
    //can only claim it once 
        require(
            callCounter < 1
        );

        callCounter = 
        callCounter + 1;
      
      //doing it through boolean   
        require (
            hasBeenClaimed == false
        );
        
            hasBeenClaimed == true; 
        
        //only fundowner can claim it 
        
        uint256 _totalFunded = totalFunded;
        totalFunded = 0;
        
        WISE_TOKEN.transfer(
            FUND_OWNER,
            _totalFunded
        );
    
    //can also prevent second claim by reseting the totalfunded to 0 
    //this will be prone to attach for reentracy 
        totalFunded = 0; 
        
    //or delete totalFunded;

//do these have to be the same parameter as within the function? 
        // emit
        emit Claim (
            FUND_OWNER,
            _totalFunded
        );
    }

    function _refundTokens(
        address _refundAddress,
        uint256 _refundAmount
    )
        private
    {
        WISE_TOKEN.transfer(
            _refundAddress,
            _refundAmount
        );
        
        emit Refund(
            _refundAddress,
            _refundAmount
        );
    }
}