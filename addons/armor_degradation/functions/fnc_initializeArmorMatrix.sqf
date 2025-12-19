#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Initializes the armor degradation matrix for a unit based on equipped gear.
 * Creates separate matrices for vest, uniform, and headgear.
 *
 * Priority for matrix generation:
 * 1. Check for custom 3D matrix in ACE_Armor_Matrix_Config
 * 2. Check for inline config in CfgWeapons/CfgVehicles >> ace_armor_degradation
 * 3. Auto-generate matrix based on armor protection parameters
 *
 * Arguments:
 * 0: Unit <OBJECT> - The unit to initialize armor for
 *
 * Return Value:
 * Success <BOOL> - True if initialization was successful
 *
 * Example:
 * [player] call ace_armor_degradation_fnc_initializeArmorMatrix
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {
    WARNING("initializeArmorMatrix: Null unit provided");
    false
};

// Skip if already initialized and loadout hasn't changed
private _currentLoadoutHash = hashValue [vest _unit, uniform _unit, headgear _unit];
private _storedHash = _unit getVariable [QGVAR(loadoutHash), -1];

if (_currentLoadoutHash == _storedHash) exitWith {
    TRACE_1("Armor matrix already initialized for current loadout",_unit);
    true
};

// Create armor state hashmap for this unit
private _armorState = createHashMap;

// Helper function to initialize armor piece
private _fnc_initArmorPiece = {
    params ["_className", "_armorType", "_hitpoint", "_isHeadgear"];

    if (_className == "") exitWith {};

    // Get base armor value
    private _baseArmor = [_className, _hitpoint] call EFUNC(medical_engine,getItemArmor);

    // Skip if no armor protection (except for vests which always have some structure)
    if (_baseArmor <= 0 && _armorType != "vest") exitWith {};

    // Try to get custom matrix from config first
    private _configResult = [_className, _isHeadgear] call FUNC(getArmorMatrixFromConfig);

    private _material = MATERIAL_COMPOSITE;
    private _matrix = [];

    if (!isNil "_configResult") then {
        // Use custom config matrix
        _configResult params ["_cfgMaterial", "_cfgMatrix"];

        // If material is -1, auto-detect
        _material = if (_cfgMaterial < 0) then {
            [_className] call FUNC(getArmorMaterial)
        } else {
            _cfgMaterial
        };

        _matrix = _cfgMatrix;

        // Update material in matrix cells if it was auto-detected
        if (_cfgMaterial < 0) then {
            {
                {
                    {
                        _x set [1, _material];
                    } forEach _x;
                } forEach _x;
            } forEach _matrix;
        };

        INFO_2("Using custom matrix config for %1 (material: %2)",_className,_material);
    } else {
        // Auto-generate matrix from armor parameters
        private _generatedData = [_className, _isHeadgear] call FUNC(generateMatrixFromArmorParams);
        _generatedData params ["_genMaterial", "_genMatrix"];

        _material = _genMaterial;
        _matrix = _genMatrix;

        TRACE_2("Auto-generated matrix for %1 (material: %2)",_className,_material);
    };

    // Store armor data
    _armorState set [_armorType, createHashMapFromArray [
        ["class", _className],
        ["matrix", _matrix],
        ["material", _material],
        ["baseArmor", _baseArmor],
        ["configDefined", !isNil "_configResult"]
    ]];

    TRACE_3("Initialized %1 matrix: %2 (material: %3)",_armorType,_className,_material);
};

// Initialize vest armor matrix
private _vestClass = vest _unit;
[_vestClass, "vest", "HitChest", false] call _fnc_initArmorPiece;

// Initialize uniform armor matrix (if provides protection)
private _uniformClass = uniform _unit;
[_uniformClass, "uniform", "HitChest", false] call _fnc_initArmorPiece;

// Initialize headgear armor matrix
private _headgearClass = headgear _unit;
[_headgearClass, "headgear", "HitHead", true] call _fnc_initArmorPiece;

// Store armor state on unit
_unit setVariable [QGVAR(armorState), _armorState, true];
_unit setVariable [QGVAR(loadoutHash), _currentLoadoutHash, true];

// Add to global cache for performance
GVAR(armorMatrixCache) set [hashValue _unit, _armorState];

INFO_1("Armor matrix initialized for %1",_unit);

true
