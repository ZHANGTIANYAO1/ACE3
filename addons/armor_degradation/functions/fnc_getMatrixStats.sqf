#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Gets statistical information about an armor matrix.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit
 * 1: Armor Type <STRING> - "vest", "uniform", or "headgear"
 *
 * Return Value:
 * Stats <HASHMAP> - Statistical information about the armor
 *
 * Example:
 * [player, "vest"] call ace_armor_degradation_fnc_getMatrixStats
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_armorType", "vest", [""]]
];

if (isNull _unit) exitWith { createHashMap };

private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];
private _armorData = _armorState get _armorType;

if (isNil "_armorData") exitWith { createHashMap };

private _matrix = _armorData get "matrix";

private _minIntegrity = 1;
private _maxIntegrity = 0;
private _totalIntegrity = 0;
private _totalHits = 0;
private _cellCount = 0;
private _damagedCells = 0;
private _criticalCells = 0;

{
    {
        {
            _x params ["_integrity", "", "_hits"];

            _minIntegrity = _minIntegrity min _integrity;
            _maxIntegrity = _maxIntegrity max _integrity;
            _totalIntegrity = _totalIntegrity + _integrity;
            _totalHits = _totalHits + _hits;
            _cellCount = _cellCount + 1;

            if (_integrity < 1) then { _damagedCells = _damagedCells + 1 };
            if (_integrity < 0.3) then { _criticalCells = _criticalCells + 1 };
        } forEach _x;
    } forEach _x;
} forEach _matrix;

createHashMapFromArray [
    ["avgIntegrity", if (_cellCount > 0) then { _totalIntegrity / _cellCount } else { 1 }],
    ["minIntegrity", _minIntegrity],
    ["maxIntegrity", _maxIntegrity],
    ["totalHits", _totalHits],
    ["cellCount", _cellCount],
    ["damagedCells", _damagedCells],
    ["criticalCells", _criticalCells],
    ["damagedPercent", if (_cellCount > 0) then { _damagedCells / _cellCount } else { 0 }],
    ["criticalPercent", if (_cellCount > 0) then { _criticalCells / _cellCount } else { 0 }],
    ["material", _armorData get "material"],
    ["baseArmor", _armorData get "baseArmor"]
]
