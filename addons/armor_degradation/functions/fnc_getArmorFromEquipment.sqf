#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Gets armor protection values from equipment configuration.
 *
 * Arguments:
 * 0: Class Name <STRING> - Equipment class name
 * 1: Hitpoint <STRING> (optional) - Specific hitpoint, empty for all
 *
 * Return Value:
 * Armor Value <NUMBER or HASHMAP> - Armor values
 *
 * Example:
 * ["V_PlateCarrier1_rgr"] call ace_armor_degradation_fnc_getArmorFromEquipment
 * ["V_PlateCarrier1_rgr", "HitChest"] call ace_armor_degradation_fnc_getArmorFromEquipment
 *
 * Public: Yes
 */

params [
    ["_className", "", [""]],
    ["_hitpoint", "", [""]]
];

if (_className == "") exitWith {
    if (_hitpoint == "") then { createHashMap } else { 0 }
};

private _configPath = configFile >> "CfgWeapons" >> _className;
if (!isClass _configPath) then {
    _configPath = configFile >> "CfgVehicles" >> _className;
};

if (!isClass _configPath) exitWith {
    if (_hitpoint == "") then { createHashMap } else { 0 }
};

private _itemInfo = _configPath >> "ItemInfo";
private _hitpointsInfo = _itemInfo >> "HitpointsProtectionInfo";

if (_hitpoint != "") exitWith {
    private _hitpointConfig = _hitpointsInfo >> _hitpoint;
    if (isClass _hitpointConfig) then {
        getNumber (_hitpointConfig >> "armor")
    } else {
        0
    }
};

// Return all hitpoints
private _result = createHashMap;
private _hitpoints = ["Head", "Chest", "Diaphragm", "Abdomen", "Pelvis", "Body", "Legs", "Arms"];

{
    private _hpConfig = _hitpointsInfo >> _x;
    if (isClass _hpConfig) then {
        _result set [_x, getNumber (_hpConfig >> "armor")];
    };
} forEach _hitpoints;

_result
