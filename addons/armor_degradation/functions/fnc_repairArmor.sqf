#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Repairs armor by a specified amount. Cannot exceed original integrity.
 * Different materials have different repair limits.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit
 * 1: Armor Type <STRING> - "vest", "uniform", or "headgear"
 * 2: Repair Amount <NUMBER> (optional) - Amount to repair (0-1)
 * 3: Zones <ARRAY> (optional) - Specific zones to repair, empty for all
 *
 * Return Value:
 * New Integrity <NUMBER> - Average integrity after repair
 *
 * Example:
 * [player, "vest", 0.3] call ace_armor_degradation_fnc_repairArmor
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_armorType", "vest", [""]],
    ["_repairAmount", 0.2, [0]],
    ["_zones", [], [[]]]
];

if (!GVAR(enableRepair)) exitWith {
    WARNING("Armor repair is disabled in settings");
    0
};

if (isNull _unit) exitWith { 0 };

private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];
private _armorData = _armorState get _armorType;

if (isNil "_armorData") exitWith {
    WARNING_2("repairArmor: No armor of type %1 on %2",_armorType,_unit);
    0
};

private _matrix = _armorData get "matrix";
private _material = _armorData get "material";

// Determine max repair based on material
// Ceramic can't be fully repaired, steel can
private _maxRepair = switch (_material) do {
    case MATERIAL_CERAMIC: { 0.6 };      // Ceramic shatters - limited repair
    case MATERIAL_STEEL: { 0.95 };       // Steel can be hammered back
    case MATERIAL_TITANIUM: { 0.90 };
    case MATERIAL_SOFT_KEVLAR: { 0.7 };  // Fibers can't be fully restored
    case MATERIAL_HARD_KEVLAR: { 0.75 };
    case MATERIAL_UHMWPE: { 0.8 };
    case MATERIAL_COMPOSITE: { 0.65 };   // Ceramic layer limits repair
    default { 0.8 };
};

// Apply repair
[_matrix, "repair", [_repairAmount * GVAR(repairEffectiveness), _maxRepair], _zones] call FUNC(batchProcessMatrix);

// Update state
_unit setVariable [QGVAR(armorState), _armorState, true];

// Calculate and return new average integrity
private _newIntegrity = [_unit, _armorType] call FUNC(getArmorIntegrity);

// Fire event
[QGVAR(armorRepaired), [_unit, _armorType, _newIntegrity]] call CBA_fnc_localEvent;

INFO_3("Armor repaired: %1 %2 to %3",_unit,_armorType,_newIntegrity);

_newIntegrity
