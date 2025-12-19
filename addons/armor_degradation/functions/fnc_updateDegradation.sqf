#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Event handler for updating armor degradation.
 * Can be called remotely to sync armor state across network.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit to update
 * 1: Armor Type <STRING> - "vest", "uniform", or "headgear"
 * 2: Zone Data <ARRAY> - [[layer, row, col, newIntegrity], ...]
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "vest", [[1,1,1,0.8]]] call ace_armor_degradation_fnc_updateDegradation
 *
 * Public: No (event handler)
 */

params [
    ["_unit", objNull, [objNull]],
    ["_armorType", "vest", [""]],
    ["_zoneData", [], [[]]]
];

if (isNull _unit) exitWith {};
if (!local _unit) exitWith {};

private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];
private _armorData = _armorState get _armorType;

if (isNil "_armorData") exitWith {
    WARNING_2("updateDegradation: No armor data for %1 on %2",_armorType,_unit);
};

private _matrix = _armorData get "matrix";

// Apply zone updates
{
    _x params ["_layer", "_row", "_col", "_newIntegrity"];

    private _cell = [_matrix, _layer, _row, _col] call FUNC(getMatrixValue);
    if (_cell != []) then {
        _cell set [0, _newIntegrity];
        _cell set [3, time];
    };
} forEach _zoneData;

// Save updated state
_unit setVariable [QGVAR(armorState), _armorState, true];

TRACE_3("Updated degradation for %1 %2: %3 zones",_unit,_armorType,count _zoneData);
