#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Gets the complete armor state for a unit or specific armor type.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit
 * 1: Armor Type <STRING> (optional) - "vest", "uniform", or "headgear". Empty for all.
 *
 * Return Value:
 * Armor State <HASHMAP or ARRAY> - Armor state data
 *
 * Example:
 * [player] call ace_armor_degradation_fnc_getArmorState
 * [player, "vest"] call ace_armor_degradation_fnc_getArmorState
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_armorType", "", [""]]
];

if (isNull _unit) exitWith { createHashMap };

private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];

if (_armorType == "") exitWith { _armorState };

_armorState getOrDefault [_armorType, createHashMap]
