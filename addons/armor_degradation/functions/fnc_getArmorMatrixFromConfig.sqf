#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Gets custom armor matrix from config if defined, otherwise returns nil.
 * Checks both ACE config and CfgWeapons/CfgVehicles for matrix definitions.
 *
 * Arguments:
 * 0: Class Name <STRING> - The armor class name
 * 1: Is Headgear <BOOL> (default: false) - Whether this is headgear (uses 2x2x2 matrix)
 *
 * Return Value:
 * Matrix Config <ARRAY or NIL> - [material, 3DMatrix] or nil if not configured
 *
 * Example:
 * ["V_PlateCarrier1_rgr", false] call ace_armor_degradation_fnc_getArmorMatrixFromConfig
 *
 * Public: Yes
 */

params [
    ["_className", "", [""]],
    ["_isHeadgear", false, [false]]
];

if (_className == "") exitWith { nil };

// Check cache first
private _cacheKey = format ["matrixConfig_%1", _className];
private _cached = GVAR(caliberDamageCache) get _cacheKey;
if (!isNil "_cached") exitWith { _cached };

private _result = nil;

// Try to find config in ACE_Armor_Matrix_Config
private _configPath = configFile >> "ACE_Armor_Matrix_Config" >> _className;

if (isClass _configPath) then {
    private _material = getNumber (_configPath >> "material");
    private _layers = if (_isHeadgear) then { 2 } else { 3 };
    private _rows = if (_isHeadgear) then { 2 } else { 3 };
    private _cols = if (_isHeadgear) then { 2 } else { 3 };

    private _matrix = [];

    for "_l" from 0 to (_layers - 1) do {
        private _layerConfig = _configPath >> (format ["Layer%1", _l]);
        private _layerArray = [];

        if (isClass _layerConfig) then {
            for "_r" from 0 to (_rows - 1) do {
                private _rowData = getArray (_layerConfig >> (format ["row%1", _r]));
                private _rowDataCount = count _rowData;

                // Validate and pad row data if needed
                if (_rowDataCount < _cols) then {
                    private _lastVal = if (_rowDataCount > 0) then { _rowData select (_rowDataCount - 1) } else { 1 };
                    for "_i" from _rowDataCount to (_cols - 1) do {
                        _rowData pushBack _lastVal;
                    };
                };

                // Convert coefficients to cell data format [integrity, material, hitCount, lastHitTime]
                private _rowArray = [];
                {
                    _rowArray pushBack [_x, _material, 0, 0];
                } forEach _rowData;

                _layerArray pushBack _rowArray;
            };
        } else {
            // Layer not defined, use default 1.0 values
            for "_r" from 0 to (_rows - 1) do {
                private _rowArray = [];
                for "_c" from 0 to (_cols - 1) do {
                    _rowArray pushBack [1, _material, 0, 0];
                };
                _layerArray pushBack _rowArray;
            };
        };

        _matrix pushBack _layerArray;
    };

    _result = [_material, _matrix];

    TRACE_2("Loaded custom matrix config for %1",_className,_material);
};

// Also check for ACE config in CfgWeapons/CfgVehicles
if (isNil "_result") then {
    private _itemConfig = configFile >> "CfgWeapons" >> _className;
    if (!isClass _itemConfig) then {
        _itemConfig = configFile >> "CfgVehicles" >> _className;
    };

    if (isClass _itemConfig) then {
        private _aceConfig = _itemConfig >> "ace_armor_degradation";

        if (isClass _aceConfig) then {
            private _material = getNumber (_aceConfig >> "material");
            private _layers = if (_isHeadgear) then { 2 } else { 3 };
            private _rows = if (_isHeadgear) then { 2 } else { 3 };
            private _cols = if (_isHeadgear) then { 2 } else { 3 };

            private _matrix = [];

            for "_l" from 0 to (_layers - 1) do {
                private _layerConfig = _aceConfig >> (format ["Layer%1", _l]);
                private _layerArray = [];

                if (isClass _layerConfig) then {
                    for "_r" from 0 to (_rows - 1) do {
                        private _rowData = getArray (_layerConfig >> (format ["row%1", _r]));
                        private _rowDataCount = count _rowData;

                        if (_rowDataCount < _cols) then {
                            private _lastVal = if (_rowDataCount > 0) then { _rowData select (_rowDataCount - 1) } else { 1 };
                            for "_i" from _rowDataCount to (_cols - 1) do {
                                _rowData pushBack _lastVal;
                            };
                        };

                        private _rowArray = [];
                        {
                            _rowArray pushBack [_x, _material, 0, 0];
                        } forEach _rowData;

                        _layerArray pushBack _rowArray;
                    };
                } else {
                    for "_r" from 0 to (_rows - 1) do {
                        private _rowArray = [];
                        for "_c" from 0 to (_cols - 1) do {
                            _rowArray pushBack [1, _material, 0, 0];
                        };
                        _layerArray pushBack _rowArray;
                    };
                };

                _matrix pushBack _layerArray;
            };

            _result = [_material, _matrix];

            TRACE_2("Loaded inline matrix config for %1",_className,_material);
        };
    };
};

// Cache the result (including nil)
GVAR(caliberDamageCache) set [_cacheKey, _result];

_result
