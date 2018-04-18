var Token = artifacts.require("./BrylliteToken.sol");

var tokenContract;

module.exports = function(deployer) {
    var admin = "0xcd63ab567c2727b74ad418658a99221aa3e598bb"; 
    var totalTokenAmount = 1 * 1000000000 * 100000000;
	// var totalTokenAmount = 1 * 1000000000;

    return Token.new(admin, totalTokenAmount).then(function(result) {
        tokenContract = result;
    });
};
