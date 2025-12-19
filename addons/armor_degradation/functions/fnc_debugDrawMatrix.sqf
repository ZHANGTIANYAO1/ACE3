#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Debug function to visualize armor matrix state.
 * Draws a text representation of the matrix for debugging.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit
 * 1: Armor Type <STRING> - "vest", "uniform", or "headgear"
 *
 * Return Value:
 * Debug String <STRING> - Formatted matrix visualization
 *
 * Example:
 * [player, "vest"] call ace_armor_degradation_fnc_debugDrawMatrix
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_armorType", "vest", [""]]
];

if (isNull _unit) exitWith { "No unit specified" };

private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];
private _armorData = _armorState get _armorType;

if (isNil "_armorData") exitWith { format ["No %1 armor on unit", _armorType] };

private _matrix = _armorData get "matrix";
private _material = _armorData get "material";
private _baseArmor = _armorData get "baseArmor";
private _className = _armorData get "class";

private _materialName = switch (_material) do {
    case MATERIAL_SOFT_KEVLAR: { "Soft Kevlar" };
    case MATERIAL_HARD_KEVLAR: { "Hard Kevlar" };
    case MATERIAL_CERAMIC: { "Ceramic" };
    case MATERIAL_STEEL: { "Steel" };
    case MATERIAL_TITANIUM: { "Titanium" };
    case MATERIAL_UHMWPE: { "UHMWPE" };
    case MATERIAL_COMPOSITE: { "Composite" };
    default { "Unknown" };
};

private _output = format ["=== ARMOR DEBUG: %1 ===\n", toUpper _armorType];
_output = _output + format ["Class: %1\n", _className];
_output = _output + format ["Material: %1\n", _materialName];
_output = _output + format ["Base Armor: %1\n", _baseArmor];
_output = _output + format ["Avg Integrity: %1%%\n\n", round (([_unit, _armorType] call FUNC(getArmorIntegrity)) * 100)];

// Draw matrix layers
private _layerNames = ["FRONT", "MIDDLE", "BACK"];
private _rowNames = ["Upper", "Middle", "Lower"];
private _colNames = ["L", "C", "R"];

{
    private _layerIdx = _forEachIndex;
    private _layer = _x;

    _output = _output + format ["--- Layer: %1 ---\n", _layerNames select _layerIdx];
    _output = _output + "     L    C    R\n";

    {
        private _rowIdx = _forEachIndex;
        private _row = _x;

        _output = _output + format ["%1: ", _rowNames select _rowIdx];

        {
            _x params ["_integrity", "_mat", "_hits"];
            private _pct = round (_integrity * 100);
            private _hitStr = if (_hits > 0) then { format ["(%1)", _hits] } else { "" };

            // Color coding would be nice but systemChat doesn't support it
            private _intStr = if (_pct >= 80) then {
                format ["%1%%", _pct]
            } else {
                if (_pct >= 50) then {
                    format ["%1%%", _pct]
                } else {
                    format ["%1%%!", _pct]
                };
            };

            _output = _output + format ["%1%2 ", _intStr, _hitStr];
        } forEach _row;

        _output = _output + "\n";
    } forEach _layer;

    _output = _output + "\n";
} forEach _matrix;

// Output to system chat and return
systemChat _output;

_output
