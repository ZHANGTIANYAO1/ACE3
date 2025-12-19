#include "script_component.hpp"

// Wait for CBA settings to initialize
["CBA_settingsInitialized", {
    INFO("Advanced Armor: CBA settings initialized callback received");

    if (!GVAR(enabled)) exitWith {
        INFO("Advanced Armor: System DISABLED via settings");
    };

    INFO("Advanced Armor: System ENABLED, starting initialization...");
    INFO_1("Advanced Armor: enableForAI = %1",GVAR(enableForAI));

    // Add event handler for damage events
    [QEGVAR(medical,woundReceived), LINKFUNC(handleWoundReceived)] call CBA_fnc_addEventHandler;
    INFO("Advanced Armor: Wound received event handler added");

    // Add event handler for armor equipment changes (players only)
    ["loadout", LINKFUNC(handleLoadoutChange), true] call CBA_fnc_addPlayerEventHandler;
    INFO("Advanced Armor: Loadout change event handler added");

    // Initialize armor matrix for local player
    if (hasInterface) then {
        INFO("Advanced Armor: hasInterface=true, waiting for player object...");
        [{!isNull player}, {
            INFO_1("Advanced Armor: Player object ready, initializing matrix for %1",player);
            [player] call FUNC(initializeArmorMatrix);
            INFO("Advanced Armor: Player matrix initialization complete");
        }] call CBA_fnc_waitUntilAndExecute;
    } else {
        INFO("Advanced Armor: hasInterface=false (dedicated server or headless client)");
    };

    // Only add AI handler if enabled in settings (disabled by default for performance)
    if (GVAR(enableForAI)) then {
        INFO("Advanced Armor: AI handler ENABLED, adding class event handler");
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
    } else {
        INFO("Advanced Armor: AI handler DISABLED (default for performance)");
    };

    // Event handler for armor degradation updates (can be called remotely)
    [QGVAR(updateDegradation), LINKFUNC(updateDegradation)] call CBA_fnc_addEventHandler;

    // Event handler for armor repair
    [QGVAR(repairArmor), LINKFUNC(repairArmor)] call CBA_fnc_addEventHandler;

    // Event handler for armor replacement
    [QGVAR(replaceArmor), LINKFUNC(replaceArmor)] call CBA_fnc_addEventHandler;

    INFO("Advanced Armor: === INITIALIZATION COMPLETE ===");
}] call CBA_fnc_addEventHandler;
