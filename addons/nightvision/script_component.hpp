#define COMPONENT nightvision
#define COMPONENT_BEAUTIFIED Night Vision
#include "\z\ace\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_NIGHTVISION
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_NIGHTVISION
    #define DEBUG_SETTINGS DEBUG_SETTINGS_NIGHTVISION
#endif

#include "\z\ace\addons\main\script_macros.hpp"


// Effect Settings / Magic values to tweak:

#define NVG_GREEN_PRESET colorPreset[] = {0, {0.0, 0.0, 0.0, 0.0}, {1.3, 1.2, 0.0, 0.9}, {6, 1, 1, 0.0}}
#define NVG_WHITE_PRESET colorPreset[] = {0.0, {0.0, 0.0, 0.0, 0.0}, {1.1, 0.8, 1.9, 0.9}, {1, 1, 6, 0.0}}

// Decreases fog when in air vehicles
#define ST_NVG_AIR_FOG_MULTIPLIER 0.5

// Increase blur when looking down sights
#define ST_NVG_CAMERA_BLUR_SIGHTS_RIFLE 6
#define ST_NVG_CAMERA_BLUR_SIGHTS_PISTOL 2

#define ST_NVG_MINFOG 0.2
#define ST_NVG_MAXFOG 0.3

#define ST_NVG_GRAIN_MIN 2.25
#define ST_NVG_GRAIN_MAX 2.7

#define ST_NVG_BLUR_MIN 0.05
#define ST_NVG_BLUR_MAX 0.11

#define ST_NVG_BRIGHT_MIN 0.65
#define ST_NVG_BRIGHT_MAX 0.75

#define ST_NVG_CONTRAST_MIN 0.4
#define ST_NVG_CONTRAST_MAX 0.8

#define ST_NVG_NOISEINTENSITY_MIN 0.4
#define ST_NVG_NOISEINTENSITY_MAX 0.55

#define ST_NVG_NOISESHARPNESS_MIN 1.2
#define ST_NVG_NOISESHARPNESS_MAX 1

#define IS_MAGNIFIED (0.75 call CBA_fnc_getFOV select 1 > 3.01)
