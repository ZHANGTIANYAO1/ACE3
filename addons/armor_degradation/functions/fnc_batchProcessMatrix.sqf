#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Batch processes multiple matrix cells using a single operation.
 * Optimized for performance by minimizing function call overhead.
 * Uses flattened arrays for cache-friendly memory access patterns.
 *
 * Arguments:
 * 0: Matrix <ARRAY> - The 3D armor matrix
 * 1: Operation <STRING> - Operation type: "degrade", "repair", "scale", "reset"
 * 2: Parameters <ARRAY> - Operation-specific parameters
 * 3: Zone Mask <ARRAY> (optional) - List of [layer,row,col] to process (empty = all)
 *
 * Return Value:
 * Success <BOOL> - True if operation completed successfully
 *
 * Example:
 * [_matrix, "degrade", [0.1, MATERIAL_CERAMIC], [[0,1,1], [1,1,1]]] call ace_armor_degradation_fnc_batchProcessMatrix
 *
 * Public: Yes
 */

params ["_matrix", "_operation", "_params", ["_zoneMask", []]];

if (_matrix isEqualTo []) exitWith { false };

private _layers = count _matrix;
private _rows = count (_matrix select 0);
private _cols = count ((_matrix select 0) select 0);

// If no zone mask, process all cells
private _processAll = _zoneMask isEqualTo [];

// Pre-compute zones to process for better performance
private _zonesToProcess = if (_processAll) then {
    private _zones = [];
    for "_l" from 0 to (_layers - 1) do {
        for "_r" from 0 to (_rows - 1) do {
            for "_c" from 0 to (_cols - 1) do {
                _zones pushBack [_l, _r, _c];
            };
        };
    };
    _zones
} else {
    _zoneMask
};

// Process based on operation type
switch (toLower _operation) do {
    case "degrade": {
        _params params [["_amount", 0.1], ["_material", -1]];

        {
            _x params ["_l", "_r", "_c"];
            private _cell = ((_matrix select _l) select _r) select _c;
            _cell params ["_integrity", "_cellMaterial", "_hitCount", "_lastHit"];

            // Skip if material filter doesn't match
            if (_material != -1 && _cellMaterial != _material) then { continue };

            // Get material-specific degradation rate
            private _materialRate = GVAR(materialDegradationRates) getOrDefault [_cellMaterial, 0.1];
            private _actualDegradation = _amount * _materialRate * GVAR(degradationMultiplier);

            // Apply degradation
            private _newIntegrity = (_integrity - _actualDegradation) max (GVAR(minArmorIntegrity));
            _cell set [0, _newIntegrity];
            _cell set [2, _hitCount + 1];
            _cell set [3, time];
        } forEach _zonesToProcess;
    };

    case "repair": {
        _params params [["_amount", 0.1], ["_maxRepair", 0.8]];

        {
            _x params ["_l", "_r", "_c"];
            private _cell = ((_matrix select _l) select _r) select _c;
            _cell params ["_integrity"];

            // Repair with diminishing returns based on damage
            private _repairAmount = _amount * GVAR(repairEffectiveness);
            private _newIntegrity = (_integrity + _repairAmount) min _maxRepair;
            _cell set [0, _newIntegrity];
        } forEach _zonesToProcess;
    };

    case "scale": {
        _params params [["_factor", 1]];

        {
            _x params ["_l", "_r", "_c"];
            private _cell = ((_matrix select _l) select _r) select _c;
            _cell params ["_integrity"];

            private _newIntegrity = (_integrity * _factor) max MIN_ARMOR_INTEGRITY min MAX_ARMOR_INTEGRITY;
            _cell set [0, _newIntegrity];
        } forEach _zonesToProcess;
    };

    case "reset": {
        _params params [["_value", MAX_ARMOR_INTEGRITY]];

        {
            _x params ["_l", "_r", "_c"];
            private _cell = ((_matrix select _l) select _r) select _c;
            _cell set [0, _value];
            _cell set [2, 0];
            _cell set [3, 0];
        } forEach _zonesToProcess;
    };

    default {
        WARNING_1("batchProcessMatrix: Unknown operation %1",_operation);
        false
    };
};

true
