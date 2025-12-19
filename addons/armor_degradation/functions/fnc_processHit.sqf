#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Processes a hit on armor and returns modified damage based on degradation.
 * Called during damage calculation to factor in armor condition.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit being hit
 * 1: Hitpoint <STRING> - The hitpoint name
 * 2: Damage <NUMBER> - Incoming damage
 * 3: Ammo Class <STRING> - Class name of the projectile
 * 4: Impact Position <ARRAY> - World position of impact
 *
 * Return Value:
 * Modified Damage <NUMBER> - Damage after armor degradation factor applied
 *
 * Example:
 * [player, "HitChest", 0.5, "B_556x45_Ball", getPosASL player] call ace_armor_degradation_fnc_processHit
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_hitpoint", "HitChest", [""]],
    ["_damage", 0, [0]],
    ["_ammoClass", "", [""]],
    ["_impactPos", [0,0,0], [[]]]
];

if (!GVAR(enabled)) exitWith { _damage };
if (isNull _unit) exitWith { _damage };
if (_damage <= 0) exitWith { _damage };

// Determine armor type from hitpoint
private _armorType = switch (toLower _hitpoint) do {
    case "hithead": { "headgear" };
    case "hitchest";
    case "hitdiaphragm";
    case "hitabdomen";
    case "hitpelvis";
    case "hitbody": { "vest" };
    default { "vest" };
};

// Get armor state
private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];
private _armorData = _armorState get _armorType;

// If no armor of this type, check uniform
if (isNil "_armorData" && _armorType != "headgear") then {
    _armorData = _armorState get "uniform";
    if (!isNil "_armorData") then {
        _armorType = "uniform";
    };
};

// No armor protection at all
if (isNil "_armorData") exitWith { _damage };

private _matrix = _armorData get "matrix";
private _baseArmor = _armorData get "baseArmor";

// Get hit zones
private _direction = vectorDir _unit; // Simplified, actual direction from handleDamage would be better
private _zones = [_hitpoint, _impactPos, _unit, _direction] call FUNC(getHitZone);

// Calculate average integrity in hit zones
private _totalIntegrity = 0;
private _zoneCount = 0;

{
    _x params ["_layer", "_row", "_col"];
    private _cell = [_matrix, _layer, _row, _col] call FUNC(getMatrixValue);

    if !(_cell isEqualTo []) then {
        _totalIntegrity = _totalIntegrity + (_cell select 0);
        _zoneCount = _zoneCount + 1;
    };
} forEach _zones;

private _avgIntegrity = if (_zoneCount > 0) then {
    _totalIntegrity / _zoneCount
} else {
    1
};

// Calculate effective armor
// Degraded armor provides less protection
private _effectiveArmor = _baseArmor * _avgIntegrity;

// Calculate damage modification
// Less armor = more damage passes through
private _armorFactor = if (_baseArmor > 0) then {
    _effectiveArmor / _baseArmor
} else {
    1
};

// Inverse relationship: lower integrity = higher damage multiplier
private _damageMultiplier = 1 + (1 - _armorFactor);

// Apply to damage
private _modifiedDamage = _damage * _damageMultiplier;

TRACE_5("processHit: hitpoint=%1 baseDamage=%2 integrity=%3 multiplier=%4 modifiedDamage=%5",_hitpoint,_damage,_avgIntegrity,_damageMultiplier,_modifiedDamage);

_modifiedDamage
