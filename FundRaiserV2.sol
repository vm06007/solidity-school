// SPDX-License-Identifier: -- 💰️ --

pragma solidity ^0.8.0;

contract WiseFundRaiser {

    address public immutable FUND_OWNER;
    address public immutable WISE_TOKEN;

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
        WISE_TOKEN = _wiseToken;
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
        require(
            block.timestamp < TIMESTAMP,
            'WiseFundRaiser: closed'
        );

        address tokenHolder = msg.sender;
        uint256 tokenAmount = _tokenAmount;

        if (totalFunded + _tokenAmount > THRESHOLD) {

            uint256 requiredAmount = THRESHOLD - totalFunded;
            uint256 refundAmount = _tokenAmount - requiredAmount;

            tokenAmount = requiredAmount;

            _safeTransfer(
                tokenHolder,
                refundAmount
            );
        }

        totalFunded =
        totalFunded + tokenAmount;

        balanceMap[tokenHolder] =
        balanceMap[tokenHolder] + tokenAmount;

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

        address refundAddress = msg.sender;

        uint256 refundAmount = balanceMap[refundAddress];
        balanceMap[refundAddress] = 0;

        _safeTransfer(
            refundAddress,
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

        _safeTransfer(
            FUND_OWNER,
            THRESHOLD
        );

        // emit
    }

    // --------------------
    // HELPER FUNCTIONS (PRIVATE)

    bytes4 private constant TRANSFER = bytes4(
        keccak256(
            bytes(
                'transfer(address,uint256)'
            )
        )
    );

    function _safeTransfer(
        address _to,
        uint256 _value
    )
        private
    {
        (bool success, bytes memory data) = WISE_TOKEN.call(
            abi.encodeWithSelector(
                TRANSFER,
                _to,
                _value
            )
        );

        require(
            success && (
                data.length == 0 || abi.decode(
                    data, (bool)
                )
            ),
            'safeTransfer: transfer failed'
        );
    }
}
