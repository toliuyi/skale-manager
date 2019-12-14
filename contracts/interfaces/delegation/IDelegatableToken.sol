/*
    IDelegatableToken.sol - SKALE Manager
    Copyright (C) 2019-Present SKALE Labs
    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity ^0.5.3;
/**
    @notice Token that can be used for delegation, unlocked
*/
interface IDelegatableToken {

    /**
        @notice returns if the token is locked
        @param wallet of the wallet
        @return true if token is locked
    */
    function getLockedOf(address wallet) external returns (bool);

    /**
            @notice returns if the token is delegated
            @param wallet address of the wallet
            @return true if the token is delegated
    */
    function getDelegatedOf(address wallet) external returns (bool);
}
