#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Gets the base degradation rate for a specific armor material.
 * Uses cached values with setting overrides.
 *
 * Arguments:
 * 0: Material Type <NUMBER> - The MATERIAL_* constant
 *
 * Return Value:
 * Degradation Rate <NUMBER> - Base degradation rate (0-1)
 *
 * Example:
 * [MATERIAL_CERAMIC] call ace_armor_degradation_fnc_getMaterialDegradationRate
 *
 * Public: Yes
 */

params [["_material", MATERIAL_COMPOSITE, [0]]];

// Check for user-configured overrides first
private _rate = switch (_material) do {
    case MATERIAL_CERAMIC: { GVAR(ceramicDegradationRate) };
    case MATERIAL_STEEL: { GVAR(steelDegradationRate) };
    default {
        // Use default from cache
        GVAR(materialDegradationRates) getOrDefault [_material, 0.1]
    };
};

_rate
