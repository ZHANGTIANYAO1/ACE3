#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Gets the overall integrity of an armor piece (average of all zones).
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit
 * 1: Armor Type <STRING> - "vest", "uniform", or "headgear"
 *
 * Return Value:
 * Integrity <NUMBER> - Average integrity (0-1)
 *
 * Example:
 * [player, "vest"] call ace_armor_degradation_fnc_getArmorIntegrity
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_armorType", "vest", [""]]
];

if (isNull _unit) exitWith { 1 };

private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];
private _armorData = _armorState get _armorType;

if (isNil "_armorData") exitWith { 1 };

private _matrix = _armorData get "matrix";
if (isNil "_matrix" || _matrix isEqualTo []) exitWith { 1 };

// Calculate average integrity across all cells
private _totalIntegrity = 0;
private _cellCount = 0;

{
    {
        {
            _x params ["_integrity"];
            _totalIntegrity = _totalIntegrity + _integrity;
            _cellCount = _cellCount + 1;
        } forEach _x;
    } forEach _x;
} forEach _matrix;

if (_cellCount == 0) exitWith { 1 };

_totalIntegrity / _cellCount
