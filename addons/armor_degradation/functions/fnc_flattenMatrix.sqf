#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Flattens a 3D matrix into a 1D array for efficient storage/transmission.
 * This enables faster serialization and potential SIMD-style batch operations.
 *
 * Arguments:
 * 0: Matrix <ARRAY> - The 3D armor matrix to flatten
 *
 * Return Value:
 * Flattened Data <ARRAY> - [dimensions, flattenedValues]
 *   dimensions: [layers, rows, cols]
 *   flattenedValues: 1D array of all cell data
 *
 * Example:
 * [_matrix] call ace_armor_degradation_fnc_flattenMatrix
 *
 * Public: Yes
 */

params ["_matrix"];

if (_matrix isEqualTo []) exitWith {
    [[0, 0, 0], []]
};

private _layers = count _matrix;
private _rows = count (_matrix select 0);
private _cols = count ((_matrix select 0) select 0);

// Pre-allocate array for performance (total cells)
private _totalCells = _layers * _rows * _cols;
private _flatArray = [];
_flatArray resize _totalCells;

// Flatten using computed indices for cache-friendly access
private _index = 0;
{
    private _layerArray = _x;
    {
        private _rowArray = _x;
        {
            _flatArray set [_index, _x];
            _index = _index + 1;
        } forEach _rowArray;
    } forEach _layerArray;
} forEach _matrix;

[[_layers, _rows, _cols], _flatArray]
