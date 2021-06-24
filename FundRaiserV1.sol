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
}

contract WiseFundRaiser {

    address public immutable FUND_OWNER;
    address public immutable WISE_TOKEN_A;

    ITokenContract public immutable WISE_TOKEN;

    uint256 public immutable THRESHOLD;
    uint256 public immutable TIMESTAMP;

    uint256 public totalFunded;

    mapping(address => uint256) balanceMap;

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

        uint256 tokenAmount = _tokenAmount;

        if (totalFunded + _tokenAmount > THRESHOLD) {

            uint256 requiredAmount = THRESHOLD - totalFunded;
            uint256 refundAmount = _tokenAmount - requiredAmount;

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

        // emit
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

        WISE_TOKEN.transfer(
            FUND_OWNER,
            totalFunded
        );

        // emit
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
    }
}