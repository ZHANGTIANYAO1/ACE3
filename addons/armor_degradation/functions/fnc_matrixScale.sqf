#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Scales all integrity values in the matrix by a factor.
 * Used for batch degradation or repair operations.
 * Optimized for performance using flattened operations.
 *
 * Arguments:
 * 0: Matrix <ARRAY> - The 3D armor matrix
 * 1: Scale Factor <NUMBER> - Multiplier for all integrity values
 * 2: Clamp Min <NUMBER> (default: 0) - Minimum resulting value
 * 3: Clamp Max <NUMBER> (default: 1) - Maximum resulting value
 *
 * Return Value:
 * Matrix <ARRAY> - Modified matrix (also modifies in place)
 *
 * Example:
 * [_matrix, 0.9] call ace_armor_degradation_fnc_matrixScale
 * [_matrix, 1.2, 0, 1] call ace_armor_degradation_fnc_matrixScale  // Repair with cap
 *
 * Public: Yes
 */

params ["_matrix", "_scaleFactor", ["_clampMin", MIN_ARMOR_INTEGRITY], ["_clampMax", MAX_ARMOR_INTEGRITY]];

// Iterate through all cells and scale integrity values
{
    private _layerArray = _x;
    {
        private _rowArray = _x;
        {
            _x params ["_integrity", "_material", "_hitCount", "_lastHitTime"];

            // Scale and clamp integrity
            private _newIntegrity = (_integrity * _scaleFactor) max _clampMin min _clampMax;

            // Update in place
            _x set [0, _newIntegrity];
        } forEach _rowArray;
    } forEach _layerArray;
} forEach _matrix;

_matrix
