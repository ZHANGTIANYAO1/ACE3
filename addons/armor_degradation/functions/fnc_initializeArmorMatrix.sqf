#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Initializes the armor degradation matrix for a unit based on equipped gear.
 * Creates separate matrices for vest, uniform, and headgear.
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

// Initialize vest armor matrix
private _vestClass = vest _unit;
if (_vestClass != "") then {
    private _vestMaterial = [_vestClass] call FUNC(getArmorMaterial);
    private _vestMatrix = [MATRIX_LAYERS, MATRIX_ROWS, MATRIX_COLS, MAX_ARMOR_INTEGRITY, _vestMaterial] call FUNC(createEmptyMatrix);

    _armorState set ["vest", createHashMapFromArray [
        ["class", _vestClass],
        ["matrix", _vestMatrix],
        ["material", _vestMaterial],
        ["baseArmor", [_vestClass, "HitChest"] call EFUNC(medical_engine,getItemArmor)]
    ]];

    TRACE_2("Initialized vest matrix",_vestClass,_vestMaterial);
};

// Initialize uniform armor matrix (if provides protection)
private _uniformClass = uniform _unit;
if (_uniformClass != "") then {
    private _uniformArmor = [_uniformClass, "HitChest"] call EFUNC(medical_engine,getItemArmor);

    // Only create matrix if uniform provides armor
    if (_uniformArmor > 0) then {
        private _uniformMaterial = [_uniformClass] call FUNC(getArmorMaterial);
        private _uniformMatrix = [MATRIX_LAYERS, MATRIX_ROWS, MATRIX_COLS, MAX_ARMOR_INTEGRITY, _uniformMaterial] call FUNC(createEmptyMatrix);

        _armorState set ["uniform", createHashMapFromArray [
            ["class", _uniformClass],
            ["matrix", _uniformMatrix],
            ["material", _uniformMaterial],
            ["baseArmor", _uniformArmor]
        ]];

        TRACE_2("Initialized uniform matrix",_uniformClass,_uniformMaterial);
    };
};

// Initialize headgear armor matrix
private _headgearClass = headgear _unit;
if (_headgearClass != "") then {
    private _headgearArmor = [_headgearClass, "HitHead"] call EFUNC(medical_engine,getItemArmor);

    if (_headgearArmor > 0) then {
        private _headgearMaterial = [_headgearClass] call FUNC(getArmorMaterial);
        // Headgear uses smaller matrix (2x2x2) for simplified zones
        private _headgearMatrix = [2, 2, 2, MAX_ARMOR_INTEGRITY, _headgearMaterial] call FUNC(createEmptyMatrix);

        _armorState set ["headgear", createHashMapFromArray [
            ["class", _headgearClass],
            ["matrix", _headgearMatrix],
            ["material", _headgearMaterial],
            ["baseArmor", _headgearArmor]
        ]];

        TRACE_2("Initialized headgear matrix",_headgearClass,_headgearMaterial);
    };
};

// Store armor state on unit
_unit setVariable [QGVAR(armorState), _armorState, true];
_unit setVariable [QGVAR(loadoutHash), _currentLoadoutHash, true];

// Add to global cache for performance
GVAR(armorMatrixCache) set [hashValue _unit, _armorState];

INFO_1("Armor matrix initialized for %1",_unit);

true
