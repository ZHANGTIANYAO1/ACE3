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

INFO_1("Advanced Armor: initializeArmorMatrix called for %1",_unit);

if (isNull _unit) exitWith {
    WARNING("Advanced Armor: initializeArmorMatrix - Null unit provided");
    false
};

// Cooldown check to prevent rapid re-initialization
private _lastInit = _unit getVariable [QGVAR(lastInitTime), -1];
private _timeSinceInit = time - _lastInit;
if (_timeSinceInit < 1) exitWith {
    INFO_2("Advanced Armor: Cooldown active for %1 (%2 sec since last init)",_unit,_timeSinceInit);
    true
};

// Skip if already initialized and loadout hasn't changed
private _currentLoadoutStr = format ["%1_%2_%3", vest _unit, uniform _unit, headgear _unit];
private _storedLoadoutStr = _unit getVariable [QGVAR(loadoutStr), ""];

INFO_2("Advanced Armor: Current loadout: %1, Stored loadout: %2",_currentLoadoutStr,_storedLoadoutStr);

if (_currentLoadoutStr == _storedLoadoutStr && _storedLoadoutStr != "") exitWith {
    INFO_1("Advanced Armor: Matrix already initialized for current loadout %1",_unit);
    true
};

// Set initialization time
_unit setVariable [QGVAR(lastInitTime), time, false];
INFO_1("Advanced Armor: Starting matrix generation for %1",_unit);

// Create armor state hashmap for this unit
private _armorState = createHashMap;

// Helper function to initialize armor piece
private _fnc_initArmorPiece = {
    params ["_className", "_armorType", "_hitpoint", "_isHeadgear"];

    if (_className == "") exitWith {};

    // Get base armor value - try ACE medical_engine first, fallback to config lookup
    private _baseArmor = 0;
    if (!isNil "ace_medical_engine_fnc_getItemArmor") then {
        _baseArmor = [_className, _hitpoint] call ace_medical_engine_fnc_getItemArmor;
    } else {
        // Fallback: get armor from config directly
        private _configPath = configFile >> "CfgWeapons" >> _className;
        if (!isClass _configPath) then { _configPath = configFile >> "CfgVehicles" >> _className };
        if (isClass _configPath) then {
            private _hitpointConfig = _configPath >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Chest";
            if (_isHeadgear) then { _hitpointConfig = _configPath >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Head" };
            _baseArmor = getNumber (_hitpointConfig >> "armor");
        };
    };

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
INFO_1("Advanced Armor: Processing vest: %1",_vestClass);
[_vestClass, "vest", "HitChest", false] call _fnc_initArmorPiece;

// Initialize uniform armor matrix (if provides protection)
private _uniformClass = uniform _unit;
INFO_1("Advanced Armor: Processing uniform: %1",_uniformClass);
[_uniformClass, "uniform", "HitChest", false] call _fnc_initArmorPiece;

// Initialize headgear armor matrix
private _headgearClass = headgear _unit;
INFO_1("Advanced Armor: Processing headgear: %1",_headgearClass);
[_headgearClass, "headgear", "HitHead", true] call _fnc_initArmorPiece;

// Store armor state on unit
_unit setVariable [QGVAR(armorState), _armorState, true];
_unit setVariable [QGVAR(loadoutStr), _currentLoadoutStr, false];

// Add to global cache for performance (use unit netId for MP compatibility)
private _cacheKey = if (isMultiplayer) then { netId _unit } else { str _unit };
GVAR(armorMatrixCache) set [_cacheKey, _armorState];

INFO_2("Advanced Armor: Matrix initialization COMPLETE for %1, armor pieces: %2",_unit,count keys _armorState);

true
