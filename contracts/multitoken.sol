pragma solidity ^0.5.0;

import "openzeppelin-solidity/math/SafeMath.sol";
import 'openzeppelin-solidity/ownership/Ownable.sol';
/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract multitoken is Ownable {
    using SafeMath for uint256;

    struct TokenType {
        uint price;                             //price in base fungible token
        string name;                            //token name
        string symbol;                          //token symbol
        mapping(address => uint256) balance;    //user balance
        mapping(address => mapping(address => uint256)) allowed;
    }

    mapping(uint256 => TokenType) private _tokens;
    uint256 private _tokenTypesAmount = 0;
    uint256 constant _defaultTokenId = 0;

    /**
     * @dev Constructor creates default token
     * @param _owner address Initial token owner.
     * @param _symbol string Default token symbol
     * @param _name string Default
     */
    constructor (address _owner, string memory _symbol, string memory _name, uint _initialSupply)
        public
        Ownable() {
        createNewToken(_name, _symbol, 1, _owner, _initialSupply);
    }

    /**
     * @dev Total number of token types
     */
    function totalSupply() public view returns (uint256) {
        return _tokenTypesAmount;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner, uint256 tokenId) public view returns (uint256) {
        require(tokenId < _tokenTypesAmount);
        return _tokens[tokenId].balance[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender, uint256 tokenId) public view returns (uint256) {
        return _tokens[tokenId].allowed[owner][spender];
    }

    /**
     * @dev Transfer token for a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value, uint256 tokenId) public returns (bool) {
        _transfer(msg.sender, to, value, tokenId);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value, uint256 tokenId) public returns (bool) {
        _approve(msg.sender, spender, value, tokenId);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value, uint256 tokenId) public returns (bool) {
        _transfer(from, to, value, tokenId);
        _approve(from, msg.sender, _tokens[tokenId].allowed[from][msg.sender].sub(value), tokenId);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue, uint256 tokenId) public returns (bool) {
        _approve(msg.sender, spender, _tokens[tokenId].allowed[msg.sender][spender].add(addedValue), tokenId);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue, uint256 tokenId) public returns (bool) {
        _approve(msg.sender, spender, _tokens[tokenId].allowed[msg.sender][spender].sub(subtractedValue), tokenId);
        return true;
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value, uint256 tokenId) internal {
        require(to != address(0));
        require(tokenId < _tokenTypesAmount);

        _tokens[tokenId].balance[from] = _tokens[tokenId].balance[from].sub(value);
        _tokens[tokenId].balance[to] = _tokens[tokenId].balance[to].add(value);
        //Fix event
        //emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value, uint256 tokenId) internal {
        require(account != address(0));
        require(tokenId < _tokenTypesAmount);

        _tokens[tokenId].balance[account] = _tokens[tokenId].balance[account].add(value);
        //emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value, uint256 tokenId) internal {
        require(account != address(0));
        require(tokenId < _tokenTypesAmount);

        _tokens[tokenId].balance[account] = _tokens[tokenId].balance[account].sub(value);
        //emit Transfer(account, address(0), value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value, uint256 tokenId) internal {
        require(spender != address(0));
        require(owner != address(0));
        require(tokenId <= _tokenTypesAmount);

        _tokens[tokenId].allowed[owner][spender] = value;
        //emit Approval(owner, spender, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value, uint256 tokenId) internal {
        _burn(account, value, tokenId);
        _approve(account, msg.sender, _tokens[tokenId].allowed[account][msg.sender].sub(value), tokenId);
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    function createNewToken(string memory _name, string memory _symbol, uint _price, address _initialHolder, uint256 _value) public returns (uint256) {
        require(_price > 0);

        uint256 _newTokenId = _tokenTypesAmount;
        _tokenTypesAmount = _tokenTypesAmount.add(1);

        _tokens[_newTokenId].name = _name;
        _tokens[_newTokenId].symbol = _symbol;
        _tokens[_newTokenId].price = _price;

        _mint(_initialHolder, _value, _newTokenId);
    }

    function exchangeTokens(address _holder, uint256 _tokensToBuy, uint256 _tokenToSpendId, uint256 _tokenToBuyId, bool _coverMismatchWithDefaultToken) public {
        uint256 price = _tokens[_tokenToBuyId].price * _tokensToBuy;
        uint256 availableFunds = _tokens[_tokenToSpendId].price * _tokens[_tokenToSpendId].balance[_holder];
        uint256 tokensToSpend;
        uint256 mismatch;

        //_holder has enough _tokenToSpendId for paying
        if (price <= availableFunds) {
            tokensToSpend = price / _tokens[_tokenToSpendId].price;
            mismatch = price % _tokens[_tokenToSpendId].price;

            if (mismatch != 0) {
                //this means that tokens are not proportional
                //and here possible 2 situations
                //for example, token1 costs 3 default tokens, and token2 costs 5 default tokens
                //user has 10 token1 and 10 default tokens, so he can spend 1 token1 and cover mismatch in 2 tokens with default tokens
                //or user can spend 2 token1 and receive mismatch as in default tokens
                if (_coverMismatchWithDefaultToken && mismatch <= _tokens[_defaultTokenId].balance[_holder]) {
                    _burn(_holder, mismatch, _defaultTokenId);
                }
                else {
                    tokensToSpend = _tokenToSpendId.add(1);
                    _mint(_holder, _tokens[_tokenToSpendId].price - mismatch, _defaultTokenId);
                }
            }
        }
        else if (_coverMismatchWithDefaultToken && availableFunds + _tokens[_defaultTokenId].balance[_holder] > price) {
            //this situation possible when _holder hasn't enough tokens he want to spent to buy other tokens, but
            //he allows to cover difference with default token and he has needed amount of default tokens to do this
            //for example if user has 3 tokens that costs 3 default tokens, and he wants to buy 2 tokens that costs 5 default tokens,
            //he can spend that 3 tokens + 1 default
            tokensToSpend = _tokens[_tokenToSpendId].balance[_holder];
            _burn(_holder, price - availableFunds, _defaultTokenId);
        }
        else {
            revert("Not enough funds");
        }
        _burn(_holder, tokensToSpend, _tokenToSpendId);
        _mint(_holder, _tokensToBuy, _tokenToBuyId);
    }

    function getTokensAmount() public view returns(uint256) {
        return _tokenTypesAmount;
    }

    function getTokenName(uint256 _tokenId) public view returns(string memory) {
        return _tokens[_tokenId].name;
    }

    function getTokenSymbol(uint256 _tokenId) public view returns(string memory) {
        return _tokens[_tokenId].symbol;
    }

    function getTokenPrice(uint256 _tokenId) public view returns(uint) {
        return _tokens[_tokenId].price;
    }

    function getTokenBalance(uint256 _tokenId, address _owner) public view returns(uint256) {
        return _tokens[_tokenId].balance[_owner];
    }

}