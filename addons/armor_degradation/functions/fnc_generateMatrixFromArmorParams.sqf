#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Auto-generates a 3D armor matrix based on the armor's protection parameters.
 * Uses the armor's base protection values to create a realistic distribution
 * of protection across different zones.
 *
 * Arguments:
 * 0: Class Name <STRING> - The armor class name
 * 1: Is Headgear <BOOL> (default: false) - Whether this is headgear
 *
 * Return Value:
 * Generated Matrix Data <ARRAY> - [material, 3DMatrix]
 *
 * Example:
 * ["V_PlateCarrier1_rgr", false] call ace_armor_degradation_fnc_generateMatrixFromArmorParams
 *
 * Public: Yes
 */

params [
    ["_className", "", [""]],
    ["_isHeadgear", false, [false]]
];

if (_className == "") exitWith {
    private _defaultMatrix = [MATRIX_LAYERS, MATRIX_ROWS, MATRIX_COLS, MAX_ARMOR_INTEGRITY, MATERIAL_COMPOSITE] call FUNC(createEmptyMatrix);
    [MATERIAL_COMPOSITE, _defaultMatrix]
};

// Get config path
private _configPath = configFile >> "CfgWeapons" >> _className;
if (!isClass _configPath) then {
    _configPath = configFile >> "CfgVehicles" >> _className;
};

// Default values
private _material = MATERIAL_COMPOSITE;
private _baseArmorValue = 0;
private _passThrough = 1;

if (isClass _configPath) then {
    // Try to get armor values from ItemInfo >> HitpointsProtectionInfo
    private _itemInfo = _configPath >> "ItemInfo";
    private _hitpointsInfo = _itemInfo >> "HitpointsProtectionInfo";

    // Get the primary hitpoint for this armor type
    private _primaryHitpoint = if (_isHeadgear) then { "Head" } else { "Chest" };
    private _hitpointConfig = _hitpointsInfo >> _primaryHitpoint;

    if (isClass _hitpointConfig) then {
        _baseArmorValue = getNumber (_hitpointConfig >> "armor");
        _passThrough = getNumber (_hitpointConfig >> "passThrough");
        if (_passThrough == 0) then { _passThrough = 1 };
    };

    // Also check Body hitpoint if Chest not found
    if (_baseArmorValue == 0 && !_isHeadgear) then {
        _hitpointConfig = _hitpointsInfo >> "Body";
        if (isClass _hitpointConfig) then {
            _baseArmorValue = getNumber (_hitpointConfig >> "armor");
            _passThrough = getNumber (_hitpointConfig >> "passThrough");
            if (_passThrough == 0) then { _passThrough = 1 };
        };
    };

    // Detect material type
    _material = [_className] call FUNC(getArmorMaterial);
};

// Calculate protection coefficient based on armor value
// Higher armor value = higher base protection coefficient
// Normalize to a 0-1 scale based on typical armor ranges (0-40)
private _protectionCoef = (_baseArmorValue / 40) min 1 max 0.1;

// Define zone distribution templates based on armor type and protection level
// High protection armors have more uniform distribution
// Lower protection armors have more variation between zones

private _layers = if (_isHeadgear) then { 2 } else { MATRIX_LAYERS };
private _rows = if (_isHeadgear) then { 2 } else { MATRIX_ROWS };
private _cols = if (_isHeadgear) then { 2 } else { MATRIX_COLS };

// Get default template from config
private _templateConfig = if (_isHeadgear) then {
    configFile >> "ACE_Armor_Matrix_Config" >> "DefaultHeadgear"
} else {
    configFile >> "ACE_Armor_Matrix_Config" >> "Default"
};

// Generate the matrix
private _matrix = [];

for "_l" from 0 to (_layers - 1) do {
    private _layerArray = [];
    private _layerConfig = _templateConfig >> (format ["Layer%1", _l]);

    // Layer depth factor - front layer has highest protection
    private _layerFactor = switch (_l) do {
        case 0: { 1.0 };    // Front - main protection
        case 1: { 0.7 };    // Middle
        case 2: { 0.85 };   // Back - back plate
        default { 0.8 };
    };

    for "_r" from 0 to (_rows - 1) do {
        private _rowArray = [];

        // Try to get template values from config
        private _templateRow = if (isClass _layerConfig) then {
            getArray (_layerConfig >> (format ["row%1", _r]))
        } else {
            []
        };

        for "_c" from 0 to (_cols - 1) do {
            // Get template coefficient or calculate based on position
            private _templateCoef = if (_c < count _templateRow) then {
                _templateRow select _c
            } else {
                // Calculate based on position if no template
                private _colFactor = switch (_c) do {
                    case 0: { 0.6 };  // Left side - less protection
                    case 1: { 1.0 };  // Center - plate coverage
                    case 2: { 0.6 };  // Right side - less protection
                    default { 0.8 };
                };

                private _rowFactor = switch (_r) do {
                    case 0: { 0.9 };  // Upper - good coverage
                    case 1: { 1.0 };  // Middle - best coverage
                    case 2: { 0.7 };  // Lower - reduced coverage
                    default { 0.8 };
                };

                _colFactor * _rowFactor
            };

            // Calculate final zone coefficient
            // Combines: base protection, layer factor, template coefficient
            private _zoneCoef = _protectionCoef * _layerFactor * _templateCoef;

            // Clamp to valid range
            _zoneCoef = _zoneCoef max 0.05 min 1.0;

            // Cell data: [integrity, material, hitCount, lastHitTime]
            // Initial integrity is based on the zone coefficient (represents initial armor quality)
            _rowArray pushBack [_zoneCoef, _material, 0, 0];
        };

        _layerArray pushBack _rowArray;
    };

    _matrix pushBack _layerArray;
};

TRACE_4("Generated matrix from params: class=%1 armor=%2 material=%3 coef=%4",_className,_baseArmorValue,_material,_protectionCoef);

[_material, _matrix]
