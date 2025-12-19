#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Calculates and returns the effective armor value for a hitpoint,
 * taking degradation into account.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit
 * 1: Hitpoint <STRING> - The hitpoint to calculate armor for
 *
 * Return Value:
 * Effective Armor <NUMBER> - Armor value after degradation
 *
 * Example:
 * [player, "HitChest"] call ace_armor_degradation_fnc_calculateEffectiveArmor
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_hitpoint", "HitChest", [""]]
];

if (isNull _unit) exitWith { 0 };

// Get base armor from equipment
private _baseArmor = [_unit, _hitpoint] call EFUNC(medical_engine,getHitpointArmor);

if (!GVAR(enabled)) exitWith { _baseArmor };

// Determine armor type
private _armorType = switch (toLower _hitpoint) do {
    case "hithead": { "headgear" };
    default { "vest" };
};

// Get armor state
private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];
private _armorData = _armorState get _armorType;

if (isNil "_armorData") then {
    _armorData = _armorState get "uniform";
};

if (isNil "_armorData") exitWith { _baseArmor };

// Get overall integrity of the armor
private _integrity = [_unit, _armorType] call FUNC(getArmorIntegrity);

// Calculate effective armor
private _effectiveArmor = _baseArmor * _integrity;

TRACE_4("Effective armor: unit=%1 hitpoint=%2 base=%3 effective=%4",_unit,_hitpoint,_baseArmor,_effectiveArmor);

_effectiveArmor
