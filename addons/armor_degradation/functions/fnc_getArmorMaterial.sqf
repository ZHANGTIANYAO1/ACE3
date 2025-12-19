#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Determines the armor material type from equipment class config.
 * Checks for ACE config entries first, then falls back to heuristics.
 *
 * Arguments:
 * 0: Class Name <STRING> - The equipment class name
 *
 * Return Value:
 * Material Type <NUMBER> - One of the MATERIAL_* constants
 *
 * Example:
 * ["V_PlateCarrier1_rgr"] call ace_armor_degradation_fnc_getArmorMaterial
 *
 * Public: Yes
 */

params [["_className", "", [""]]];

if (_className == "") exitWith {
    MATERIAL_SOFT_KEVLAR
};

// Check cache first
private _cacheKey = format ["material_%1", _className];
private _cached = GVAR(caliberDamageCache) get _cacheKey;
if (!isNil "_cached") exitWith { _cached };

// Try to get material from ACE config
private _configPath = configFile >> "CfgWeapons" >> _className;
if (!isClass _configPath) then {
    _configPath = configFile >> "CfgVehicles" >> _className;
};

private _material = MATERIAL_COMPOSITE; // Default

if (isClass _configPath) then {
    // Check for ACE-specific material config
    private _aceMaterial = getNumber (_configPath >> "ace_armor_degradation_material");
    if (_aceMaterial > 0) exitWith {
        _material = _aceMaterial;
    };

    // Heuristic detection based on class name and properties
    private _displayName = toLower getText (_configPath >> "displayName");
    private _armorValue = getNumber (_configPath >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Chest" >> "armor");

    // Detect material type from naming conventions
    _material = switch (true) do {
        case ("ceramic" in _displayName): { MATERIAL_CERAMIC };
        case ("steel" in _displayName): { MATERIAL_STEEL };
        case ("titanium" in _displayName): { MATERIAL_TITANIUM };
        case ("plate" in _displayName && _armorValue > 20): { MATERIAL_CERAMIC };
        case ("carrier" in _displayName): { MATERIAL_COMPOSITE };
        case ("kevlar" in _displayName): { MATERIAL_HARD_KEVLAR };
        case ("soft" in _displayName): { MATERIAL_SOFT_KEVLAR };
        case ("light" in _displayName && _armorValue < 10): { MATERIAL_SOFT_KEVLAR };
        case ("heavy" in _displayName): { MATERIAL_STEEL };
        case (_armorValue > 30): { MATERIAL_COMPOSITE };
        case (_armorValue > 15): { MATERIAL_HARD_KEVLAR };
        case (_armorValue > 5): { MATERIAL_SOFT_KEVLAR };
        default { MATERIAL_COMPOSITE };
    };
};

// Cache the result
GVAR(caliberDamageCache) set [_cacheKey, _material];

_material
