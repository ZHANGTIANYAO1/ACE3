#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Reconstructs a 3D matrix from flattened data.
 * Inverse operation of fnc_flattenMatrix.
 *
 * Arguments:
 * 0: Flattened Data <ARRAY> - [dimensions, flattenedValues] from flattenMatrix
 *
 * Return Value:
 * Matrix <ARRAY> - Reconstructed 3D armor matrix
 *
 * Example:
 * [_flattenedData] call ace_armor_degradation_fnc_unflattenMatrix
 *
 * Public: Yes
 */

params ["_flattenedData"];

_flattenedData params ["_dimensions", "_flatArray"];
_dimensions params ["_layers", "_rows", "_cols"];

if (_layers == 0 || _rows == 0 || _cols == 0) exitWith {
    []
};

// Reconstruct 3D matrix
private _matrix = [];
private _index = 0;

for "_layer" from 0 to (_layers - 1) do {
    private _layerArray = [];
    for "_row" from 0 to (_rows - 1) do {
        private _rowArray = [];
        for "_col" from 0 to (_cols - 1) do {
            _rowArray pushBack (_flatArray select _index);
            _index = _index + 1;
        };
        _layerArray pushBack _rowArray;
    };
    _matrix pushBack _layerArray;
};

_matrix
