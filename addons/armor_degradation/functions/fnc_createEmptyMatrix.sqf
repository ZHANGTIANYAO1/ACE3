#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Creates an empty 3D armor matrix with specified dimensions and initial values.
 * Matrix structure: [layer][row][col] where each cell contains armor integrity (0-1)
 *
 * Arguments:
 * 0: Layers <NUMBER> (default: 3) - Depth layers (outer/middle/inner)
 * 1: Rows <NUMBER> (default: 3) - Vertical zones (upper/middle/lower)
 * 2: Columns <NUMBER> (default: 3) - Horizontal zones (left/center/right)
 * 3: Initial Value <NUMBER> (default: 1) - Starting integrity value
 * 4: Material Type <NUMBER> (default: MATERIAL_COMPOSITE) - Armor material
 *
 * Return Value:
 * 3D Matrix <ARRAY> - Nested array structure with armor data
 *
 * Example:
 * [] call ace_armor_degradation_fnc_createEmptyMatrix
 * [3, 3, 3, 1, MATERIAL_CERAMIC] call ace_armor_degradation_fnc_createEmptyMatrix
 *
 * Public: Yes
 */

params [
    ["_layers", MATRIX_LAYERS, [0]],
    ["_rows", MATRIX_ROWS, [0]],
    ["_cols", MATRIX_COLS, [0]],
    ["_initialValue", MAX_ARMOR_INTEGRITY, [0]],
    ["_material", MATERIAL_COMPOSITE, [0]]
];

// Create the 3D matrix structure
// Each cell contains: [integrity, material, hitCount, lastHitTime]
private _matrix = [];

for "_layer" from 0 to (_layers - 1) do {
    private _layerArray = [];
    for "_row" from 0 to (_rows - 1) do {
        private _rowArray = [];
        for "_col" from 0 to (_cols - 1) do {
            // Cell data structure:
            // [0] integrity: Current armor integrity (0-1)
            // [1] material: Material type constant
            // [2] hitCount: Number of hits this zone has taken
            // [3] lastHitTime: Game time of last hit (for time-based calculations)
            _rowArray pushBack [_initialValue, _material, 0, 0];
        };
        _layerArray pushBack _rowArray;
    };
    _matrix pushBack _layerArray;
};

_matrix
