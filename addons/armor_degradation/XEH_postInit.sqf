#include "script_component.hpp"

// Wait for CBA settings to initialize
["CBA_settingsInitialized", {
    if (!GVAR(enabled)) exitWith {
        INFO("Armor Degradation system disabled via settings");
    };

    INFO("Armor Degradation system initializing...");

    // Add event handler for damage events
    [QEGVAR(medical,woundReceived), LINKFUNC(handleWoundReceived)] call CBA_fnc_addEventHandler;

    // Add event handler for armor equipment changes
    ["loadout", LINKFUNC(handleLoadoutChange), true] call CBA_fnc_addPlayerEventHandler;

    // Initialize armor matrix for local player
    if (hasInterface) then {
        [player] call FUNC(initializeArmorMatrix);
    };

    // Add class event handler for all units
    ["CAManBase", "init", {
        params ["_unit"];
        [_unit] call FUNC(initializeArmorMatrix);
    }, true, [], true] call CBA_fnc_addClassEventHandler;

    // Event handler for armor degradation updates (can be called remotely)
    [QGVAR(updateDegradation), LINKFUNC(updateDegradation)] call CBA_fnc_addEventHandler;

    // Event handler for armor repair
    [QGVAR(repairArmor), LINKFUNC(repairArmor)] call CBA_fnc_addEventHandler;

    // Event handler for armor replacement
    [QGVAR(replaceArmor), LINKFUNC(replaceArmor)] call CBA_fnc_addEventHandler;

    INFO("Armor Degradation system initialized");
}] call CBA_fnc_addEventHandler;
