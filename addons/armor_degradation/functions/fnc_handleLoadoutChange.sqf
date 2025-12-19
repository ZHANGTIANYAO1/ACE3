#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Handles loadout changes to update armor matrices.
 * Called when player changes equipment.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit whose loadout changed
 * 1: New Loadout <ARRAY> - New loadout array
 *
 * Return Value:
 * None
 *
 * Example:
 * Called via CBA player event handler
 *
 * Public: No (event handler)
 */

params [
    ["_unit", objNull, [objNull]],
    ["_newLoadout", [], [[]]]
];

if (isNull _unit) exitWith {};
if (!local _unit) exitWith {};

// Get current loadout hash
private _newHash = hashValue [vest _unit, uniform _unit, headgear _unit];
private _oldHash = _unit getVariable [QGVAR(loadoutHash), -1];

// Only reinitialize if loadout actually changed
if (_newHash != _oldHash) then {
    TRACE_2("Loadout changed, reinitializing armor matrix",_unit,_newHash);

    // Preserve degradation for items that didn't change
    private _oldState = _unit getVariable [QGVAR(armorState), createHashMap];
    private _oldVest = _oldState getOrDefault ["vest", createHashMap] getOrDefault ["class", ""];
    private _oldUniform = _oldState getOrDefault ["uniform", createHashMap] getOrDefault ["class", ""];
    private _oldHeadgear = _oldState getOrDefault ["headgear", createHashMap] getOrDefault ["class", ""];

    // Initialize new armor
    [_unit] call FUNC(initializeArmorMatrix);

    // Restore degradation for unchanged items
    private _newState = _unit getVariable [QGVAR(armorState), createHashMap];

    if (vest _unit == _oldVest && _oldVest != "") then {
        private _oldVestData = _oldState get "vest";
        if (!isNil "_oldVestData") then {
            _newState set ["vest", _oldVestData];
        };
    };

    if (uniform _unit == _oldUniform && _oldUniform != "") then {
        private _oldUniformData = _oldState get "uniform";
        if (!isNil "_oldUniformData") then {
            _newState set ["uniform", _oldUniformData];
        };
    };

    if (headgear _unit == _oldHeadgear && _oldHeadgear != "") then {
        private _oldHeadgearData = _oldState get "headgear";
        if (!isNil "_oldHeadgearData") then {
            _newState set ["headgear", _oldHeadgearData];
        };
    };

    _unit setVariable [QGVAR(armorState), _newState, true];
};
