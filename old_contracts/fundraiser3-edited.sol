// SPDX-License-Identifier: -- 💰️ --

pragma solidity ^0.8.0;

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

    function transferFrom(
        address _from,
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

    ITokenContract public immutable WISE_TOKEN;

    address public immutable FUND_OWNER;
    uint256 public immutable THRESHOLD;
    uint256 public immutable TIMESTAMP;

    uint256 public totalFunded;
    
    mapping(address => uint256) public balanceMap;
    
    uint256 public countFunders; 
    
    mapping(uint256 => address) public partcipantAddresses;

    event Partcipant(
        counter,
        partcipantAddress
    );
    
    event Claim(
        address indexed fundOwner, 
        uint256 totalFunded 
    ); 

    event Refund(
        address indexed refundAddress,
        uint256 amount
    );

    event Fund(
        address indexed funderAddress,
        uint256 tokenAmount
    );

    event Fundraiser(
        address indexed fundOwner,
        uint256 amount, 
        uint256 timestamp
    );

    constructor(
        address _wiseToken,
        address _fundOwner,
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

        emit Fundraiser(
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
        require(
            block.timestamp < TIMESTAMP,
            'WiseFundRaiser: closed'
        );
        
        require(
            totalFunded < THRESHOLD,
            'WiseFundRaiser: fully funded'
        );
        
        uint256 tokenAmount = _adjustAmount(
            totalFunded,
            _tokenAmount,
            THRESHOLD
        );

        WISE_TOKEN.transferFrom(
            msg.sender,
            address(this),
            tokenAmount
        );

        totalFunded =
        totalFunded + tokenAmount;
        
        if (balanceMap[msg.sender] == 0) {
           //person is funding this contract for the first time
            //store address 
            countFunders = 
            countFunders + 1;
            partcipantAddresses[countFunders] = msg.sender;
            
            emit Partcipant(
                countFunders,
                msg.sender
            );
        }

        balanceMap[msg.sender] =
        balanceMap[msg.sender] + tokenAmount;

        emit Fund(
            msg.sender,
            tokenAmount
        );
    }

    function _adjustAmount(
        uint256 _totalFunded,
        uint256 _tokenAmount,
        uint256 _thresholdAmount
    )
        private
        pure
        returns (uint256)
    {
        return _isOverflow(_tokenAmount, _totalFunded, _thresholdAmount)
            ? _thresholdAmount - _totalFunded
            : _tokenAmount;
    }

    function refundTokens()
        external
    {
        require(
            block.timestamp > TIMESTAMP,
            'WiseFundRaiser: not closed yet'
        );

        require(
            totalFunded < THRESHOLD && totalFunded > 0,
            'WiseFundRaise: Invalid amount'
        );

        _refundTokens(
            msg.sender,
            balanceMap[msg.sender]
        );

    }
    
    function _sendTokens (
        address _fundOwner,
        uint256 _totalAmount
    )
        private
    {
        totalFunded = 0;

        WISE_TOKEN.transfer(
            _fundOwner,
            _totalAmount
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
        
        _sendTokens(
            FUND_OWNER,
            totalFunded
        ); 
        
        emit Claim (
            FUND_OWNER,
            totalFunded
        );
    }

    function _isOverflow(
        uint256 _totalFunded,
        uint256 _tokenAmount,
        uint256 _threshold 
    )
        private
        pure
        returns (bool)
    {
        return _totalFunded + _tokenAmount > _threshold;
    }

    function _refundTokens(
        address _refundAddress,
        uint256 _refundAmount
    )
        private
    {
        balanceMap[msg.sender] = 0;
        
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