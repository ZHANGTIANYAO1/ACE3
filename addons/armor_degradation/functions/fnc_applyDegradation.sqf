#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Applies degradation to specific zones in the armor matrix.
 * Core function for updating armor state after a hit.
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit whose armor is degrading
 * 1: Armor Type <STRING> - "vest", "uniform", or "headgear"
 * 2: Zones <ARRAY> - Array of [layer, row, col] zones to degrade
 * 3: Degradation Amount <NUMBER> - Base degradation to apply
 * 4: Projectile Info <ARRAY> (optional) - [caliber, velocity] for detailed calculation
 *
 * Return Value:
 * New Average Integrity <NUMBER> - Average integrity after degradation
 *
 * Example:
 * [player, "vest", [[1,1,1]], 0.1, [5.56, 900]] call ace_armor_degradation_fnc_applyDegradation
 *
 * Public: Yes
 */

params [
    ["_unit", objNull, [objNull]],
    ["_armorType", "vest", [""]],
    ["_zones", [[1,1,1]], [[]]],
    ["_baseDegradation", 0.1, [0]],
    ["_projectileInfo", [5.56, 900], [[]]]
];

if (isNull _unit) exitWith {
    WARNING("applyDegradation: Null unit");
    1
};

// Get armor state
private _armorState = _unit getVariable [QGVAR(armorState), createHashMap];
if (_armorState isEqualTo createHashMap) exitWith {
    WARNING_1("applyDegradation: No armor state for unit %1",_unit);
    1
};

private _armorData = _armorState get _armorType;
if (isNil "_armorData") exitWith {
    TRACE_2("No armor of type %1 on unit %2",_armorType,_unit);
    1
};

private _matrix = _armorData get "matrix";
private _material = _armorData get "material";
_projectileInfo params [["_caliber", 5.56], ["_velocity", 900]];

private _totalIntegrity = 0;
private _cellCount = 0;

// Apply degradation to each affected zone
{
    _x params ["_layer", "_row", "_col"];

    private _cell = [_matrix, _layer, _row, _col] call FUNC(getMatrixValue);
    if (_cell isEqualTo []) then { continue };

    _cell params ["_currentIntegrity", "_cellMaterial", "_hitCount", "_lastHit"];

    // Calculate zone-specific degradation
    private _degradation = [
        _cellMaterial,
        _baseDegradation,
        _caliber,
        _velocity,
        _currentIntegrity
    ] call FUNC(calculateDegradation);

    // Apply degradation
    private _newIntegrity = (_currentIntegrity - _degradation) max GVAR(minArmorIntegrity);

    // Update cell
    _cell set [0, _newIntegrity];
    _cell set [2, _hitCount + 1];
    _cell set [3, time];

    TRACE_5("Zone [%1,%2,%3] degraded: %4 -> %5",_layer,_row,_col,_currentIntegrity,_newIntegrity);

    _totalIntegrity = _totalIntegrity + _newIntegrity;
    _cellCount = _cellCount + 1;
} forEach _zones;

// Calculate and store average integrity
private _avgIntegrity = if (_cellCount > 0) then {
    _totalIntegrity / _cellCount
} else {
    1
};

// Update global armor state
_unit setVariable [QGVAR(armorState), _armorState, true];

// Fire event for UI/other systems
[QGVAR(armorDegraded), [_unit, _armorType, _avgIntegrity, _zones]] call CBA_fnc_localEvent;

_avgIntegrity
