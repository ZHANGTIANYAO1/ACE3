#define COMPONENT armor_degradation
#define COMPONENT_BEAUTIFIED Armor Degradation
#include "\z\ace\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_ARMOR_DEGRADATION
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_ARMOR_DEGRADATION
    #define DEBUG_SETTINGS DEBUG_SETTINGS_ARMOR_DEGRADATION
#endif

#include "\z\ace\addons\main\script_macros.hpp"

// Armor material types
#define MATERIAL_SOFT_KEVLAR 0
#define MATERIAL_HARD_KEVLAR 1
#define MATERIAL_CERAMIC 2
#define MATERIAL_STEEL 3
#define MATERIAL_TITANIUM 4
#define MATERIAL_UHMWPE 5
#define MATERIAL_COMPOSITE 6

// Armor zone indices for 3D matrix [layer][row][col]
// Layer: 0=outer, 1=middle, 2=inner
// Row: 0=upper, 1=middle, 2=lower
// Col: 0=left, 1=center, 2=right

#define MATRIX_LAYERS 3
#define MATRIX_ROWS 3
#define MATRIX_COLS 3

// Body part to matrix mapping
#define HITPOINT_HEAD "HitHead"
#define HITPOINT_BODY "HitBody"
#define HITPOINT_CHEST "HitChest"
#define HITPOINT_DIAPHRAGM "HitDiaphragm"
#define HITPOINT_ABDOMEN "HitAbdomen"
#define HITPOINT_PELVIS "HitPelvis"

// Degradation rate multipliers by material (ceramic degrades fastest, steel slowest)
#define DEGRADATION_SOFT_KEVLAR 0.15
#define DEGRADATION_HARD_KEVLAR 0.12
#define DEGRADATION_CERAMIC 0.25
#define DEGRADATION_STEEL 0.03
#define DEGRADATION_TITANIUM 0.05
#define DEGRADATION_UHMWPE 0.10
#define DEGRADATION_COMPOSITE 0.08

// Minimum armor integrity before complete failure
#define MIN_ARMOR_INTEGRITY 0.0
#define MAX_ARMOR_INTEGRITY 1.0

// Protection multiplier calculation
#define ARMOR_PROTECTION_FORMULA(integrity, baseArmor) ((integrity) * (baseArmor))
