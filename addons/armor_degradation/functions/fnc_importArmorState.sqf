#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Imports armor state from exported format.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit
 * 1: Exported State <ARRAY> - Data from exportArmorState
 *
 * Return Value:
 * Success <BOOL>
 *
 * Example:
 * [player, _exportedState] call ace_armor_degradation_fnc_importArmorState
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_exported", [], [[]]]
];

if (isNull _unit) exitWith { false };
if (_exported isEqualTo []) exitWith { false };

private _armorState = createHashMap;

{
    _x params ["_armorType", "_class", "_material", "_baseArmor", "_flatData"];

    private _matrix = [_flatData] call FUNC(unflattenMatrix);

    _armorState set [_armorType, createHashMapFromArray [
        ["class", _class],
        ["material", _material],
        ["baseArmor", _baseArmor],
        ["matrix", _matrix]
    ]];
} forEach _exported;

_unit setVariable [QGVAR(armorState), _armorState, true];

true
