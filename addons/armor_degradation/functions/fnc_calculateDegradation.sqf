#include "..\script_component.hpp"
/*
 * Author: ACE Team
 * Calculates the degradation amount for a hit on armor.
 * Takes into account material type, projectile caliber, and impact energy.
 *
 * Arguments:
 * 0: Material Type <NUMBER> - The armor material constant
 * 1: Damage Amount <NUMBER> - Raw damage from the hit
 * 2: Caliber <NUMBER> - Projectile caliber (affects penetration)
 * 3: Impact Velocity <NUMBER> - Projectile velocity at impact
 * 4: Current Integrity <NUMBER> - Current armor integrity at hit zone
 *
 * Return Value:
 * Degradation <NUMBER> - Amount of integrity to subtract (0-1)
 *
 * Example:
 * [MATERIAL_CERAMIC, 0.5, 5.56, 900, 0.9] call ace_armor_degradation_fnc_calculateDegradation
 *
 * Public: Yes
 */

params [
    ["_material", MATERIAL_COMPOSITE, [0]],
    ["_damage", 0, [0]],
    ["_caliber", 5.56, [0]],
    ["_velocity", 900, [0]],
    ["_currentIntegrity", 1, [0]]
];

// Get base degradation rate for this material
private _baseDegradationRate = GVAR(materialDegradationRates) getOrDefault [_material, 0.1];

// Calculate energy-based degradation factor
// Higher caliber and velocity = more degradation
private _kineticFactor = (_caliber * _velocity) / 5000; // Normalized kinetic factor
_kineticFactor = _kineticFactor min 3 max 0.1; // Clamp to reasonable range

// Material-specific behavior
private _materialFactor = switch (_material) do {
    // Ceramic: shatters on impact, high degradation especially on repeated hits
    case MATERIAL_CERAMIC: {
        // Ceramic gets progressively weaker after each hit
        private _integrityPenalty = 1 + (1 - _currentIntegrity) * 2;
        _baseDegradationRate * _integrityPenalty * 1.5
    };

    // Steel: very durable, slight deformation over time
    case MATERIAL_STEEL: {
        // Steel resists small calibers well but larger ones cause denting
        private _caliberPenalty = if (_caliber > 7.62) then { 1.5 } else { 0.8 };
        _baseDegradationRate * _caliberPenalty
    };

    // Titanium: good durability with weight savings
    case MATERIAL_TITANIUM: {
        _baseDegradationRate * 1.2
    };

    // Soft Kevlar: tears and deforms under repeated impacts
    case MATERIAL_SOFT_KEVLAR: {
        // More vulnerable to repeated hits
        private _hitPenalty = 1 + (1 - _currentIntegrity) * 0.5;
        _baseDegradationRate * _hitPenalty
    };

    // Hard Kevlar: more structured, resists deformation better
    case MATERIAL_HARD_KEVLAR: {
        _baseDegradationRate * 1.1
    };

    // UHMWPE: deforms but self-heals slightly, moderate degradation
    case MATERIAL_UHMWPE: {
        _baseDegradationRate * 0.9
    };

    // Composite: balanced degradation characteristics
    case MATERIAL_COMPOSITE: {
        _baseDegradationRate
    };

    default { _baseDegradationRate };
};

// Calculate final degradation
private _degradation = _damage * _materialFactor * _kineticFactor * GVAR(degradationMultiplier);

// Ensure minimum degradation for any hit that does damage
if (_damage > 0.01) then {
    _degradation = _degradation max 0.01;
};

// Cap maximum single-hit degradation (prevents one-shot armor destruction except for huge calibers)
private _maxDegradation = switch (true) do {
    case (_caliber >= 12.7): { 0.8 };  // .50 cal can nearly destroy armor
    case (_caliber >= 7.62): { 0.4 };  // Rifle rounds
    case (_caliber >= 5.56): { 0.25 }; // Intermediate rounds
    default { 0.15 };                   // Pistol rounds
};

_degradation = _degradation min _maxDegradation;

TRACE_5("Calculated degradation: mat=%1 dmg=%2 cal=%3 result=%4 maxDeg=%5",_material,_damage,_caliber,_degradation,_maxDegradation);

_degradation
