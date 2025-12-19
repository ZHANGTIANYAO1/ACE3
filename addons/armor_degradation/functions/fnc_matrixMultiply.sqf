#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Element-wise multiplication of two 3D matrices.
 * Used for applying degradation masks or material modifiers.
 * Supports broadcasting if dimensions differ.
 *
 * Arguments:
 * 0: Matrix A <ARRAY> - First 3D armor matrix
 * 1: Matrix B <ARRAY> - Second 3D matrix (or modifier matrix)
 * 2: Operation Type <NUMBER> (default: 0)
 *    0: Multiply integrity values only
 *    1: Apply B's integrity as degradation factor
 *
 * Return Value:
 * Result Matrix <ARRAY> - New matrix with multiplied values
 *
 * Example:
 * [_matrixA, _matrixB] call ace_armor_degradation_fnc_matrixMultiply
 *
 * Public: Yes
 */

params ["_matrixA", "_matrixB", ["_opType", 0]];

private _layers = count _matrixA min count _matrixB;
private _result = [];

for "_layer" from 0 to (_layers - 1) do {
    private _layerA = _matrixA select _layer;
    private _layerB = _matrixB select _layer;
    private _rows = count _layerA min count _layerB;
    private _resultLayer = [];

    for "_row" from 0 to (_rows - 1) do {
        private _rowA = _layerA select _row;
        private _rowB = _layerB select _row;
        private _cols = count _rowA min count _rowB;
        private _resultRow = [];

        for "_col" from 0 to (_cols - 1) do {
            private _cellA = _rowA select _col;
            private _cellB = _rowB select _col;

            _cellA params ["_integrityA", "_materialA", "_hitCountA", "_lastHitA"];
            _cellB params ["_integrityB"];

            private _newIntegrity = switch (_opType) do {
                case 0: { _integrityA * _integrityB };
                case 1: { _integrityA * (1 - (1 - _integrityB) * GVAR(degradationMultiplier)) };
                default { _integrityA * _integrityB };
            };

            // Clamp result
            _newIntegrity = _newIntegrity max MIN_ARMOR_INTEGRITY min MAX_ARMOR_INTEGRITY;

            _resultRow pushBack [_newIntegrity, _materialA, _hitCountA, _lastHitA];
        };

        _resultLayer pushBack _resultRow;
    };

    _result pushBack _resultLayer;
};

_result
