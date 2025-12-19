#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Determines which zone(s) in the 3D matrix were hit based on hitpoint and impact position.
 * Uses hit selection info to map to matrix coordinates.
 *
 * Arguments:
 * 0: Hitpoint <STRING> - The hitpoint name (e.g., "HitChest")
 * 1: Impact Position <ARRAY> - World position of the impact
 * 2: Unit <OBJECT> - The unit that was hit
 * 3: Direction Vector <ARRAY> (optional) - Direction of the projectile
 *
 * Return Value:
 * Zones <ARRAY> - Array of [layer, row, col] indices that were affected
 *
 * Example:
 * ["HitChest", [0,0,1], player, [0,1,0]] call ace_armor_degradation_fnc_getHitZone
 *
 * Public: Yes
 */

params [
    ["_hitpoint", "HitChest", [""]],
    ["_impactPos", [0,0,0], [[]]],
    ["_unit", objNull, [objNull]],
    ["_direction", [0,1,0], [[]]]
];

if (isNull _unit) exitWith { [[1, 1, 1]] }; // Center zone as fallback

// Get unit position and orientation for relative calculations
private _unitPos = getPosASL _unit;
private _unitDir = vectorDir _unit;
private _unitUp = vectorUp _unit;

// Calculate relative impact position
private _relativePos = _unitPos vectorDiff _impactPos;

// Determine layer (front/middle/back) based on direction
private _dotProduct = _direction vectorDotProduct _unitDir;
private _layer = switch (true) do {
    case (_dotProduct > 0.5): { 0 };   // Hit from front
    case (_dotProduct < -0.5): { 2 };  // Hit from back
    default { 1 };                      // Side hit
};

// Determine row (upper/middle/lower) based on hitpoint
private _row = switch (toLower _hitpoint) do {
    case "hithead": { 0 };
    case "hitchest": { 0 };
    case "hitdiaphragm": { 1 };
    case "hitabdomen": { 1 };
    case "hitpelvis": { 2 };
    case "hitbody": { 1 };
    case "hitleftarm";
    case "hitrightarm": { 0 };
    case "hitleftleg";
    case "hitrightleg": { 2 };
    default { 1 };
};

// Determine column (left/center/right) based on lateral position
private _rightVector = _unitDir vectorCrossProduct _unitUp;
private _lateralDot = _relativePos vectorDotProduct _rightVector;
private _col = switch (true) do {
    case (_lateralDot > 0.15): { 2 };   // Right side
    case (_lateralDot < -0.15): { 0 };  // Left side
    default { 1 };                       // Center
};

// Main hit zone
private _mainZone = [_layer, _row, _col];
private _zones = [_mainZone];

// Add adjacent zones based on spread factor (simulates bullet fragmentation/spalling)
if (GVAR(zoneSpreadFactor) > 0) then {
    private _spreadChance = GVAR(zoneSpreadFactor);

    // Potentially add adjacent zones
    private _adjacentOffsets = [
        [0, -1, 0], [0, 1, 0],  // Above/below
        [0, 0, -1], [0, 0, 1],  // Left/right
        [-1, 0, 0], [1, 0, 0]   // Layers
    ];

    {
        if (random 1 < _spreadChance) then {
            private _adjZone = [
                (_layer + (_x select 0)) max 0 min (MATRIX_LAYERS - 1),
                (_row + (_x select 1)) max 0 min (MATRIX_ROWS - 1),
                (_col + (_x select 2)) max 0 min (MATRIX_COLS - 1)
            ];

            // Don't add duplicates
            if !(_adjZone in _zones) then {
                _zones pushBack _adjZone;
            };
        };
    } forEach _adjacentOffsets;
};

TRACE_4("Hit zones determined: hitpoint=%1 layer=%2 row=%3 col=%4",_hitpoint,_layer,_row,_col);

_zones
