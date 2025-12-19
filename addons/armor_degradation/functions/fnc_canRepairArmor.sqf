#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Checks if armor can be repaired and returns repair limits.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit
 * 1: Armor Type <STRING> - "vest", "uniform", or "headgear"
 *
 * Return Value:
 * Repair Info <ARRAY> - [canRepair, currentIntegrity, maxRepairIntegrity, repairPotential]
 *
 * Example:
 * [player, "vest"] call ace_armor_degradation_fnc_canRepairArmor
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_armorType", "vest", [""]]
];

if (!GVAR(enableRepair)) exitWith { [false, 0, 0, 0] };
if (isNull _unit) exitWith { [false, 0, 0, 0] };

private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];
private _armorData = _armorState get _armorType;

if (isNil "_armorData") exitWith { [false, 0, 0, 0] };

private _material = _armorData get "material";
private _currentIntegrity = [_unit, _armorType] call FUNC(getArmorIntegrity);

// Get max repair for this material
private _maxRepair = switch (_material) do {
    case MATERIAL_CERAMIC: { 0.6 };
    case MATERIAL_STEEL: { 0.95 };
    case MATERIAL_TITANIUM: { 0.90 };
    case MATERIAL_SOFT_KEVLAR: { 0.7 };
    case MATERIAL_HARD_KEVLAR: { 0.75 };
    case MATERIAL_UHMWPE: { 0.8 };
    case MATERIAL_COMPOSITE: { 0.65 };
    default { 0.8 };
};

private _repairPotential = (_maxRepair - _currentIntegrity) max 0;
private _canRepair = _repairPotential > 0.01;

[_canRepair, _currentIntegrity, _maxRepair, _repairPotential]
