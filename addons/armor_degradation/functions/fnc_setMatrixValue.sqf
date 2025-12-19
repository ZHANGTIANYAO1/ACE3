#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Sets the value at a specific position in the 3D armor matrix.
 * Modifies the matrix in place for memory efficiency.
 *
 * Arguments:
 * 0: Matrix <ARRAY> - The 3D armor matrix
 * 1: Layer <NUMBER> - Layer index (0-2)
 * 2: Row <NUMBER> - Row index (0-2)
 * 3: Column <NUMBER> - Column index (0-2)
 * 4: Value <ARRAY> - New cell data [integrity, material, hitCount, lastHitTime]
 *
 * Return Value:
 * Success <BOOL> - True if value was set successfully
 *
 * Example:
 * [_matrix, 1, 1, 1, [0.5, MATERIAL_CERAMIC, 3, time]] call ace_armor_degradation_fnc_setMatrixValue
 *
 * Public: Yes
 */

params ["_matrix", "_layer", "_row", "_col", "_value"];

// Bounds checking
if (_layer < 0 || _layer >= count _matrix) exitWith {
    WARNING_1("setMatrixValue: Invalid layer index %1",_layer);
    false
};

private _layerArray = _matrix select _layer;
if (_row < 0 || _row >= count _layerArray) exitWith {
    WARNING_1("setMatrixValue: Invalid row index %1",_row);
    false
};

private _rowArray = _layerArray select _row;
if (_col < 0 || _col >= count _rowArray) exitWith {
    WARNING_1("setMatrixValue: Invalid column index %1",_col);
    false
};

// Set the value in place
_rowArray set [_col, _value];

true
