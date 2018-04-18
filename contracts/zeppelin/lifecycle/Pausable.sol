pragma solidity ^0.4.18;

// custom Pausable implementation for Bryllite

import "../ownership/Ownable.sol";

contract Pausable is Ownable {
  event PausePublic(bool newState);
  event PauseOwnerAdmin(bool newState);

  bool public pausedPublic = true;
  bool public pausedOwnerAdmin = false;

  address public admin;

  modifier whenNotPaused() {
    if(pausedPublic) {
      if(!pausedOwnerAdmin) {
        require(msg.sender == admin || msg.sender == owner);
      } else {
        revert();
      }
    }
    _;
  }

  function pause(bool newPausedPublic, bool newPausedOwnerAdmin) onlyOwner public {
    require(!(newPausedPublic == false && newPausedOwnerAdmin == true));

    pausedPublic = newPausedPublic;
    pausedOwnerAdmin = newPausedOwnerAdmin;

    PausePublic(newPausedPublic);
    PauseOwnerAdmin(newPausedOwnerAdmin);
  }
}
