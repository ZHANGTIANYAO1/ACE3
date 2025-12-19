#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Handles wound received events to apply armor degradation.
 * Integrates with ACE Medical damage system.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The injured unit
 * 1: Body Part <STRING> - Body part that was hit
 * 2: Damage <NUMBER> - Amount of damage received
 * 3: Shooter <OBJECT> - The entity that caused the damage
 * 4: Ammo Class <STRING> - Class name of the ammo
 * 5: Hit Selection <NUMBER> - Hit selection index (optional, from some events)
 *
 * Return Value:
 * None
 *
 * Example:
 * Called via event: [QEGVAR(medical,woundReceived), LINKFUNC(handleWoundReceived)] call CBA_fnc_addEventHandler
 *
 * Public: No (event handler)
 */

params [
    ["_unit", objNull, [objNull]],
    ["_bodyPart", "", [""]],
    ["_damage", 0, [0]],
    ["_shooter", objNull, [objNull]],
    ["_ammoClass", "", [""]]
];

// Early exit checks
if (!GVAR(enabled)) exitWith {};
if (isNull _unit) exitWith {};
if (_damage <= 0) exitWith {};

// Only process on local machine
if (!local _unit) exitWith {};

// Get ammo data for degradation calculation
private _ammoData = [_ammoClass] call EFUNC(medical_damage,getAmmoData);
_ammoData params [
    ["_hit", 0],
    ["_caliber", 5.56],
    ["_typicalSpeed", 900]
];

// Map body part to hitpoint and armor type
private _hitpoint = switch (toLower _bodyPart) do {
    case "head": { "HitHead" };
    case "body": { "HitChest" };
    case "torso": { "HitChest" };
    case "chest": { "HitChest" };
    case "diaphragm": { "HitDiaphragm" };
    case "abdomen": { "HitAbdomen" };
    case "pelvis": { "HitPelvis" };
    case "leftarm": { "HitLeftArm" };
    case "rightarm": { "HitRightArm" };
    case "leftleg": { "HitLeftLeg" };
    case "rightleg": { "HitRightLeg" };
    default { "HitChest" };
};

// Determine which armor piece protects this hitpoint
private _armorType = switch (_hitpoint) do {
    case "HitHead": { "headgear" };
    case "HitChest";
    case "HitDiaphragm";
    case "HitAbdomen";
    case "HitPelvis": { "vest" };
    default { "vest" };
};

// Check if unit has this armor type
private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];
if !(_armorType in _armorState) exitWith {
    // No armor of this type, check uniform as fallback
    if ("uniform" in _armorState && _armorType != "headgear") then {
        _armorType = "uniform";
    } else {
        TRACE_2("No armor protection for hitpoint %1 on %2",_hitpoint,_unit);
    };
};

// Get impact direction (approximation if no shooter)
private _direction = if (!isNull _shooter) then {
    (getPosASL _shooter) vectorFromTo (getPosASL _unit)
} else {
    vectorDir _unit
};

// Determine hit zones
private _zones = [_hitpoint, getPosASL _unit, _unit, _direction] call FUNC(getHitZone);

// Apply degradation
private _newIntegrity = [
    _unit,
    _armorType,
    _zones,
    _damage,
    [_caliber, _typicalSpeed]
] call FUNC(applyDegradation);

TRACE_5("Armor degradation applied: unit=%1 type=%2 damage=%3 zones=%4 newIntegrity=%5",_unit,_armorType,_damage,_zones,_newIntegrity);

// Update effective armor for the medical system
[_unit, _hitpoint] call FUNC(calculateEffectiveArmor);
