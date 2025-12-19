#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Adds a constant value to all integrity values in the matrix.
 * Useful for uniform repair or degradation.
 *
 * Arguments:
 * 0: Matrix <ARRAY> - The 3D armor matrix
 * 1: Add Value <NUMBER> - Value to add to all integrity values (can be negative)
 * 2: Clamp Min <NUMBER> (default: 0) - Minimum resulting value
 * 3: Clamp Max <NUMBER> (default: 1) - Maximum resulting value
 *
 * Return Value:
 * Matrix <ARRAY> - Modified matrix (also modifies in place)
 *
 * Example:
 * [_matrix, -0.1] call ace_armor_degradation_fnc_matrixAdd  // Reduce all by 0.1
 * [_matrix, 0.2, 0, 0.8] call ace_armor_degradation_fnc_matrixAdd  // Partial repair
 *
 * Public: Yes
 */

params ["_matrix", "_addValue", ["_clampMin", MIN_ARMOR_INTEGRITY], ["_clampMax", MAX_ARMOR_INTEGRITY]];

{
    private _layerArray = _x;
    {
        private _rowArray = _x;
        {
            _x params ["_integrity"];

            // Add and clamp
            private _newIntegrity = (_integrity + _addValue) max _clampMin min _clampMax;
            _x set [0, _newIntegrity];
        } forEach _rowArray;
    } forEach _layerArray;
} forEach _matrix;

_matrix
