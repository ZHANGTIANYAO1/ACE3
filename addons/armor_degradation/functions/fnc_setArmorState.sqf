#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Sets the armor state for a unit. Used for loading saved states or syncing.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit
 * 1: Armor State <HASHMAP> - Complete armor state to set
 * 2: Broadcast <BOOL> (optional) - Broadcast to network
 *
 * Return Value:
 * Success <BOOL>
 *
 * Example:
 * [player, _armorState, true] call ace_armor_degradation_fnc_setArmorState
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_armorState", createHashMap, [createHashMap]],
    ["_broadcast", true, [true]]
];

if (isNull _unit) exitWith { false };

_unit setVariable [QGVAR(armorState), _armorState, _broadcast];

// Update cache
GVAR(armorMatrixCache) set [hashValue _unit, _armorState];

true
