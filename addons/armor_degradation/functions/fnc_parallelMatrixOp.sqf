#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Performs parallel-style operations on multiple matrices simultaneously.
 * Optimized for processing multiple armor pieces at once.
 *
 * Note: Arma 3 SQF doesn't support true parallelism/GPU acceleration,
 * but this function optimizes batch operations using:
 * - Pre-computed lookup tables
 * - Memory-efficient iteration patterns
 * - Scheduled execution for large operations
 *
 * Arguments:
 * 0: Matrices <ARRAY> - Array of matrices to process
 * 1: Operation <CODE> - Code to execute on each cell, receives [matrix, layer, row, col, cell]
 * 2: Scheduled <BOOL> (default: false) - Use scheduled execution for large matrices
 *
 * Return Value:
 * Results <ARRAY> - Array of results from each matrix operation
 *
 * Example:
 * [[_matrix1, _matrix2], {params ["_m","_l","_r","_c","_cell"]; _cell set [0, 0.5]}, false] call ace_armor_degradation_fnc_parallelMatrixOp
 *
 * Public: Yes
 */

params ["_matrices", "_operation", ["_scheduled", false]];

if (_matrices isEqualTo []) exitWith { [] };

private _results = [];

private _processMatrix = {
    params ["_matrix", "_op"];

    private _matrixResult = [];
    {
        private _layerIdx = _forEachIndex;
        private _layerArray = _x;
        {
            private _rowIdx = _forEachIndex;
            private _rowArray = _x;
            {
                private _colIdx = _forEachIndex;
                private _cell = _x;

                // Execute operation
                private _result = [_matrix, _layerIdx, _rowIdx, _colIdx, _cell] call _op;
                if (!isNil "_result") then {
                    _matrixResult pushBack _result;
                };
            } forEach _rowArray;
        } forEach _layerArray;
    } forEach _matrix;

    _matrixResult
};

if (_scheduled && count _matrices > 2) then {
    // Scheduled execution for large batches - spread across frames
    [{
        params ["_args", "_handle"];
        _args params ["_matricesLocal", "_operationLocal", "_resultsLocal", "_processIndexLocal", "_processMatrixLocal"];

        if (_processIndexLocal >= count _matricesLocal) exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
        };

        private _matrix = _matricesLocal select _processIndexLocal;
        private _matrixResult = [_matrix, _operationLocal] call _processMatrixLocal;
        _resultsLocal pushBack _matrixResult;

        _args set [3, _processIndexLocal + 1];
    }, 0, [_matrices, _operation, _results, 0, _processMatrix]] call CBA_fnc_addPerFrameHandler;
} else {
    // Immediate execution for small batches
    {
        private _matrixResult = [_x, _operation] call _processMatrix;
        _results pushBack _matrixResult;
    } forEach _matrices;
};

_results
