#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Gets the value at a specific position in the 3D armor matrix.
 * Optimized for fast access using direct array indexing.
 *
 * Arguments:
 * 0: Matrix <ARRAY> - The 3D armor matrix
 * 1: Layer <NUMBER> - Layer index (0-2)
 * 2: Row <NUMBER> - Row index (0-2)
 * 3: Column <NUMBER> - Column index (0-2)
 *
 * Return Value:
 * Cell Data <ARRAY> - [integrity, material, hitCount, lastHitTime] or empty array if invalid
 *
 * Example:
 * [_matrix, 1, 1, 1] call ace_armor_degradation_fnc_getMatrixValue
 *
 * Public: Yes
 */

params ["_matrix", "_layer", "_row", "_col"];

// Bounds checking with early exit for performance
if (_layer < 0 || _layer >= count _matrix) exitWith {
    WARNING_1("getMatrixValue: Invalid layer index %1",_layer);
    []
};

private _layerArray = _matrix select _layer;
if (_row < 0 || _row >= count _layerArray) exitWith {
    WARNING_1("getMatrixValue: Invalid row index %1",_row);
    []
};

private _rowArray = _layerArray select _row;
if (_col < 0 || _col >= count _rowArray) exitWith {
    WARNING_1("getMatrixValue: Invalid column index %1",_col);
    []
};

_rowArray select _col
