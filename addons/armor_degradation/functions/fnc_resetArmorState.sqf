#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Resets armor state to full integrity (new armor).
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit
 * 1: Armor Type <STRING> (optional) - Specific type to reset, empty for all
 *
 * Return Value:
 * Success <BOOL>
 *
 * Example:
 * [player] call ace_armor_degradation_fnc_resetArmorState
 * [player, "vest"] call ace_armor_degradation_fnc_resetArmorState
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_armorType", "", [""]]
];

if (isNull _unit) exitWith { false };

private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];

if (_armorType == "") then {
    // Reset all armor types
    {
        private _armorData = _y;
        private _matrix = _armorData get "matrix";
        if (!isNil "_matrix") then {
            [_matrix, "reset", [MAX_ARMOR_INTEGRITY]] call FUNC(batchProcessMatrix);
        };
    } forEach _armorState;
} else {
    // Reset specific armor type
    private _armorData = _armorState get _armorType;
    if (!isNil "_armorData") then {
        private _matrix = _armorData get "matrix";
        if (!isNil "_matrix") then {
            [_matrix, "reset", [MAX_ARMOR_INTEGRITY]] call FUNC(batchProcessMatrix);
        };
    };
};

_unit setVariable [QGVAR(armorState), _armorState, true];

true
