// SPDX-License-Identifier: -- 🎁️ --

pragma solidity =0.8.0; 

contract myToken {
    
    string public name;
    string public symbol;
    uint256 public totalSupply; 
    
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;
    
    event Transfer (
        address indexed from,
        address indexed to,
        uint256 amount 
    );
    
    event Approve (
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    
    constructor (
        uint256 _totalSupply,
        string memory _symbol,
        string memory _name
    )  
        payable 
    {
        totalSupply = _totalSupply;
        symbol = _symbol;
        name = _name;
        balances[msg.sender] = _totalSupply; 
    }
    
    function transfer (
        address _recipient,
        uint256 _amount
    ) 
        external 
        returns(bool)
    {
       return _transfer (
            msg.sender, 
            _recipient, 
            _amount
        );
    }
    //declaring how much we are approving 
    function approve (
        address _spender,
        uint256 _amount
    )
        external 
    {
        //update allowances
        //who is the spender in the AMM case? Is it the user sending the tokens or is it uniswap? -> the spender is uniswap 
        allowances[msg.sender][_spender] = _amount;
        
    //emiting approval for the blockchain to see approved 
        emit Approve (
            msg.sender,
            _spender,
            _amount 
        );
        
    }
     //updating the allowances after transfer   
    function transferFrom (
        address _owner, 
        address _to,
        uint256 _amount
    )
        external 
        returns (bool)
    {
        //update allowances - sub 
        
        allowances[_owner][msg.sender] = 
        allowances[_owner][msg.sender] - _amount;
        
        return _transfer(
            _owner,
            _to,
            _amount
        );
    
        // require(currentAllowance > _amount, "Exceeds allowed amount");
        //don't need this in 0.8 because safemath already inside sol
        //keep the error message short below 32 characters so it only takes 1 byte 
    }
    //do we need a modifier here inside transfer in order to check if the amount is approved? 
    
    function _transfer (
        address _from,
        address _to, 
        uint256 _amount
    )
        internal 
        returns (bool)
    {
        
        balances[_from] = 
        balances[_from] - _amount;
            
        balances[_to] = 
        balances[_to] + _amount;
        
        emit Transfer (
            _from,
            _to,
            _amount 
        );
        return true; 
        
        //or should we just return if this transaction went through? 
        
       
    
    /* One option. I think this is correct? 
        balances[_from] = 
        balances[_from] - allowances[msg.sender][_from];
        
        balances[_to] = 
        balances[_to] + _amount;
    */ 
    }
    
    //calling interface 
}

interface tokenInstance {
    function transferFrom (
        address _owner, 
        address _to,
        uint256 _amount
    )
        external 
        returns (bool);
}


contract swapContract {
   function swap(
        address _tokenAddress,
        uint256 amount 
    ) 
        external 
        returns (bool)
    {
        tokenInstance token = tokenInstance(_tokenAddress);
        token.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        
        tokenSwap()
        return true;
    }
    
    //homework 
    //take token a and give back token b 1:1 ratio 
    //will need another interface instance
    
    
}


interface swappingTokens {
    function transferFrom(
        address = _owner,
        address = _to,
        uint256 = _amount 
    )
        external returns(bool)
}

contract tokenSwap {
    function swapAb(
    
    //declaring this address in order to call our interface of our main cnotract 
        address _contractAddress,
        address _tokenA,
        address _tokenB, 
        uint256 _amount
    ) 
        external 
        returns (bool);

        swappingTokens interfaceVarA = swappingTokens(_contractAddress);
        interfaceVarA.transferFrom(
            _tokenA,
            _tokenB, 
            _amount
        ); 
        
        interfaceVarA.transferFrom(
            _tokenB,
            _tokenA,
            _amount
        );
        
        returns true;
        
    
}

//youtube video with explanation: https://www.youtube.com/watch?v=jP1A1odqXFM

