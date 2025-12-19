#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

// Register CBA settings
#include "initSettings.inc.sqf"

// Initialize global variables
GVAR(enabled) = true;
GVAR(enableForAI) = false; // Disabled by default for performance

// Armor matrix cache - stores 3D matrices for each unit's equipped armor
// Format: HashMap<unit, HashMap<armorType, 3DMatrix>>
GVAR(armorMatrixCache) = createHashMap;

// Material degradation rates cache
GVAR(materialDegradationRates) = createHashMapFromArray [
    [MATERIAL_SOFT_KEVLAR, DEGRADATION_SOFT_KEVLAR],
    [MATERIAL_HARD_KEVLAR, DEGRADATION_HARD_KEVLAR],
    [MATERIAL_CERAMIC, DEGRADATION_CERAMIC],
    [MATERIAL_STEEL, DEGRADATION_STEEL],
    [MATERIAL_TITANIUM, DEGRADATION_TITANIUM],
    [MATERIAL_UHMWPE, DEGRADATION_UHMWPE],
    [MATERIAL_COMPOSITE, DEGRADATION_COMPOSITE]
];

// Caliber to damage conversion cache
GVAR(caliberDamageCache) = createHashMap;

// Performance optimization: pre-computed matrix indices
GVAR(matrixIndices) = [];
for "_layer" from 0 to (MATRIX_LAYERS - 1) do {
    private _layerArray = [];
    for "_row" from 0 to (MATRIX_ROWS - 1) do {
        private _rowArray = [];
        for "_col" from 0 to (MATRIX_COLS - 1) do {
            _rowArray pushBack [_layer, _row, _col];
        };
        _layerArray pushBack _rowArray;
    };
    GVAR(matrixIndices) pushBack _layerArray;
};

ADDON = true;
