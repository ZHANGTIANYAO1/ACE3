#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Replaces armor with a new piece (full integrity).
 * Simulates swapping out damaged armor plates.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit
 * 1: Armor Type <STRING> - "vest", "uniform", or "headgear"
 * 2: New Class <STRING> (optional) - New armor class, empty to use same type
 *
 * Return Value:
 * Success <BOOL>
 *
 * Example:
 * [player, "vest"] call ace_armor_degradation_fnc_replaceArmor
 * [player, "vest", "V_PlateCarrier2_rgr"] call ace_armor_degradation_fnc_replaceArmor
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_armorType", "vest", [""]],
    ["_newClass", "", [""]]
];

if (isNull _unit) exitWith { false };

private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];

// Determine the class to use
private _classToUse = if (_newClass != "") then {
    _newClass
} else {
    switch (_armorType) do {
        case "vest": { vest _unit };
        case "uniform": { uniform _unit };
        case "headgear": { headgear _unit };
        default { "" };
    }
};

if (_classToUse == "") exitWith {
    WARNING_2("replaceArmor: No armor class for type %1 on %2",_armorType,_unit);
    false
};

// Create new armor data with full integrity
private _material = [_classToUse] call FUNC(getArmorMaterial);

private _matrix = if (_armorType == "headgear") then {
    [2, 2, 2, MAX_ARMOR_INTEGRITY, _material] call FUNC(createEmptyMatrix)
} else {
    [MATRIX_LAYERS, MATRIX_ROWS, MATRIX_COLS, MAX_ARMOR_INTEGRITY, _material] call FUNC(createEmptyMatrix)
};

private _hitpoint = if (_armorType == "headgear") then { "HitHead" } else { "HitChest" };
private _baseArmor = [_classToUse, _hitpoint] call EFUNC(medical_engine,getItemArmor);

_armorState set [_armorType, createHashMapFromArray [
    ["class", _classToUse],
    ["matrix", _matrix],
    ["material", _material],
    ["baseArmor", _baseArmor]
]];

_unit setVariable [QGVAR(armorState), _armorState, true];

// Fire event
[QGVAR(armorReplaced), [_unit, _armorType, _classToUse]] call CBA_fnc_localEvent;

INFO_3("Armor replaced: %1 %2 with %3",_unit,_armorType,_classToUse);

true
