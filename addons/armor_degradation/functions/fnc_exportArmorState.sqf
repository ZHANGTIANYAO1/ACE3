#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Exports armor state to a portable format for saving/loading.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit
 *
 * Return Value:
 * Exported State <ARRAY> - Portable armor state data
 *
 * Example:
 * [player] call ace_armor_degradation_fnc_exportArmorState
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith { [] };

private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];
private _exported = [];

{
    private _armorType = _x;
    private _armorData = _y;

    private _matrix = _armorData get "matrix";
    private _flatData = [_matrix] call FUNC(flattenMatrix);

    _exported pushBack [
        _armorType,
        _armorData get "class",
        _armorData get "material",
        _armorData get "baseArmor",
        _flatData
    ];
} forEach _armorState;

_exported
