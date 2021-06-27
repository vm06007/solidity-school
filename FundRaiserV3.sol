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

    event Claim (
        address indexed fundOwner, 
        uint256 totalFunded 
    ); 

    event Refund (
        address indexed refundAddress,
        uint256 amount
    );

    event Fund (
        address indexed funderAddress,
        uint256 tokenAmount
    );

    event Fundraiser (
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
        require(
            block.timestamp < TIMESTAMP,
            'WiseFundRaiser: closed'
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
        return _isOverflow(
            _tokenAmount, 
            _totalFunded, 
            _thresholdAmount
        )
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
            totalFunded < THRESHOLD,
            'WiseFundRaiser: funds raised'
        );

        _refundTokens(
            msg.sender,
            balanceMap[msg.sender]
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
        
        uint256 _totalFunded = totalFunded;
        totalFunded = 0;
        
        WISE_TOKEN.transfer(
            FUND_OWNER,
            _totalFunded
        );
    
        emit Claim (
            FUND_OWNER,
            _totalFunded
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
        balanceMap[_refundAddress] = 0;
        
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
