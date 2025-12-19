#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Gets the overall degradation factor for a unit's armor.
 * Returns how much the armor has degraded from original state.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit
 * 1: Armor Type <STRING> (optional) - Specific type, empty for overall
 *
 * Return Value:
 * Degradation Factor <NUMBER> - 0 = no degradation, 1 = fully degraded
 *
 * Example:
 * [player] call ace_armor_degradation_fnc_getDegradationFactor
 * [player, "vest"] call ace_armor_degradation_fnc_getDegradationFactor
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_armorType", "", [""]]
];

if (isNull _unit) exitWith { 0 };

if (_armorType != "") exitWith {
    private _integrity = [_unit, _armorType] call FUNC(getArmorIntegrity);
    1 - _integrity
};

// Calculate overall degradation across all armor types
private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];
private _totalIntegrity = 0;
private _armorCount = 0;

{
    private _integrity = [_unit, _x] call FUNC(getArmorIntegrity);
    _totalIntegrity = _totalIntegrity + _integrity;
    _armorCount = _armorCount + 1;
} forEach (keys _armorState);

if (_armorCount == 0) exitWith { 0 };

1 - (_totalIntegrity / _armorCount)
