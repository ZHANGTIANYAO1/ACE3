#include "script_component.hpp"

// Wait for CBA settings to initialize
["CBA_settingsInitialized", {
    if (!GVAR(enabled)) exitWith {
        INFO("Armor Degradation system disabled via settings");
    };

    INFO("Armor Degradation system initializing...");

    // Add event handler for damage events
    [QEGVAR(medical,woundReceived), LINKFUNC(handleWoundReceived)] call CBA_fnc_addEventHandler;

    // Add event handler for armor equipment changes (players only)
    ["loadout", LINKFUNC(handleLoadoutChange), true] call CBA_fnc_addPlayerEventHandler;

    // Initialize armor matrix for local player
    if (hasInterface) then {
        [{!isNull player}, {
            [player] call FUNC(initializeArmorMatrix);
        }] call CBA_fnc_waitUntilAndExecute;
    };

    // Only add AI handler if enabled in settings (disabled by default for performance)
    if (GVAR(enableForAI)) then {
        ["CAManBase", "init", {
            params ["_unit"];
            // Skip players (handled separately) and remote units
            if (!local _unit || isPlayer _unit) exitWith {};
            // Use scheduled execution to prevent frame drops
            [{
                params ["_unit"];
                if (isNull _unit || !alive _unit) exitWith {};
                [_unit] call FUNC(initializeArmorMatrix);
            }, [_unit], 0.5 + random 1] call CBA_fnc_waitAndExecute;
        }, true, [], true] call CBA_fnc_addClassEventHandler;
    };

    // Event handler for armor degradation updates (can be called remotely)
    [QGVAR(updateDegradation), LINKFUNC(updateDegradation)] call CBA_fnc_addEventHandler;

    // Event handler for armor repair
    [QGVAR(repairArmor), LINKFUNC(repairArmor)] call CBA_fnc_addEventHandler;

    // Event handler for armor replacement
    [QGVAR(replaceArmor), LINKFUNC(replaceArmor)] call CBA_fnc_addEventHandler;

    INFO("Armor Degradation system initialized");
}] call CBA_fnc_addEventHandler;
