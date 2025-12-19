// Armor Material Definitions
// Each material has different properties affecting degradation and protection

class ACE_Armor_Materials {
    class SoftKevlar {
        displayName = "Soft Kevlar";
        materialType = MATERIAL_SOFT_KEVLAR;
        degradationRate = DEGRADATION_SOFT_KEVLAR;     // Degrades moderately
        baseProtection = 0.3;                           // NIJ Level IIA equivalent
        calibreResistance[] = {                         // Calibre vs effectiveness
            {"9x19", 0.95},
            {"45ACP", 0.90},
            {"556x45", 0.20},
            {"762x39", 0.10},
            {"762x51", 0.05}
        };
        multiHitCapability = 3;                         // Can take ~3 hits before significant degradation
        weight = 1.0;                                   // Weight multiplier
    };

    class HardKevlar {
        displayName = "Hard Kevlar";
        materialType = MATERIAL_HARD_KEVLAR;
        degradationRate = DEGRADATION_HARD_KEVLAR;
        baseProtection = 0.5;                           // NIJ Level IIIA equivalent
        calibreResistance[] = {
            {"9x19", 0.98},
            {"45ACP", 0.95},
            {"44Magnum", 0.85},
            {"556x45", 0.35},
            {"762x39", 0.20},
            {"762x51", 0.10}
        };
        multiHitCapability = 4;
        weight = 1.3;
    };

    class Ceramic {
        displayName = "Ceramic Plate";
        materialType = MATERIAL_CERAMIC;
        degradationRate = DEGRADATION_CERAMIC;          // Degrades fastest - shatters on impact
        baseProtection = 0.85;                          // NIJ Level IV equivalent
        calibreResistance[] = {
            {"9x19", 1.0},
            {"45ACP", 1.0},
            {"556x45", 0.95},
            {"762x39", 0.90},
            {"762x51", 0.85},
            {"762x54R", 0.80},
            {"127x99", 0.40}
        };
        multiHitCapability = 1;                         // Ceramic shatters - very limited multi-hit
        weight = 1.8;
    };

    class Steel {
        displayName = "Steel Plate";
        materialType = MATERIAL_STEEL;
        degradationRate = DEGRADATION_STEEL;            // Degrades slowest
        baseProtection = 0.75;                          // NIJ Level III+ equivalent
        calibreResistance[] = {
            {"9x19", 1.0},
            {"45ACP", 1.0},
            {"556x45", 0.88},
            {"762x39", 0.82},
            {"762x51", 0.75},
            {"762x54R", 0.70},
            {"127x99", 0.20}
        };
        multiHitCapability = 15;                        // Steel can take many hits
        weight = 2.5;
    };

    class Titanium {
        displayName = "Titanium Plate";
        materialType = MATERIAL_TITANIUM;
        degradationRate = DEGRADATION_TITANIUM;
        baseProtection = 0.80;
        calibreResistance[] = {
            {"9x19", 1.0},
            {"45ACP", 1.0},
            {"556x45", 0.92},
            {"762x39", 0.85},
            {"762x51", 0.78},
            {"762x54R", 0.72},
            {"127x99", 0.25}
        };
        multiHitCapability = 12;
        weight = 1.6;
    };

    class UHMWPE {
        displayName = "UHMWPE (Dyneema/Spectra)";
        materialType = MATERIAL_UHMWPE;
        degradationRate = DEGRADATION_UHMWPE;
        baseProtection = 0.70;                          // NIJ Level III equivalent
        calibreResistance[] = {
            {"9x19", 0.98},
            {"45ACP", 0.95},
            {"556x45", 0.85},
            {"762x39", 0.75},
            {"762x51", 0.65},
            {"762x54R", 0.55}
        };
        multiHitCapability = 6;
        weight = 0.8;                                   // Lightest hard armor option
    };

    class Composite {
        displayName = "Composite (Ceramic/PE)";
        materialType = MATERIAL_COMPOSITE;
        degradationRate = DEGRADATION_COMPOSITE;
        baseProtection = 0.88;                          // Best protection
        calibreResistance[] = {
            {"9x19", 1.0},
            {"45ACP", 1.0},
            {"556x45", 0.96},
            {"762x39", 0.92},
            {"762x51", 0.88},
            {"762x54R", 0.82},
            {"127x99", 0.45}
        };
        multiHitCapability = 3;
        weight = 1.5;
    };
};
