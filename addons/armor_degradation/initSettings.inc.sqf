// Armor Degradation Settings

[
    QGVAR(enabled),
    "CHECKBOX",
    [LSTRING(Setting_Enabled), LSTRING(Setting_Enabled_Desc)],
    [ELSTRING(medical,Category), LSTRING(Category)],
    true,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(enableForAI),
    "CHECKBOX",
    [LSTRING(Setting_EnableForAI), LSTRING(Setting_EnableForAI_Desc)],
    [ELSTRING(medical,Category), LSTRING(Category)],
    false,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(degradationMultiplier),
    "SLIDER",
    [LSTRING(Setting_DegradationMultiplier), LSTRING(Setting_DegradationMultiplier_Desc)],
    [ELSTRING(medical,Category), LSTRING(Category)],
    [0.1, 5, 1, 2],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(ceramicDegradationRate),
    "SLIDER",
    [LSTRING(Setting_CeramicDegradation), LSTRING(Setting_CeramicDegradation_Desc)],
    [ELSTRING(medical,Category), LSTRING(Category)],
    [0.05, 0.5, 0.25, 2],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(steelDegradationRate),
    "SLIDER",
    [LSTRING(Setting_SteelDegradation), LSTRING(Setting_SteelDegradation_Desc)],
    [ELSTRING(medical,Category), LSTRING(Category)],
    [0.01, 0.2, 0.03, 2],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(showDegradationHUD),
    "CHECKBOX",
    [LSTRING(Setting_ShowHUD), LSTRING(Setting_ShowHUD_Desc)],
    [ELSTRING(medical,Category), LSTRING(Category)],
    true,
    0
] call CBA_fnc_addSetting;

[
    QGVAR(enableRepair),
    "CHECKBOX",
    [LSTRING(Setting_EnableRepair), LSTRING(Setting_EnableRepair_Desc)],
    [ELSTRING(medical,Category), LSTRING(Category)],
    true,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(repairEffectiveness),
    "SLIDER",
    [LSTRING(Setting_RepairEffectiveness), LSTRING(Setting_RepairEffectiveness_Desc)],
    [ELSTRING(medical,Category), LSTRING(Category)],
    [0.1, 1, 0.5, 2],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(minArmorIntegrity),
    "SLIDER",
    [LSTRING(Setting_MinIntegrity), LSTRING(Setting_MinIntegrity_Desc)],
    [ELSTRING(medical,Category), LSTRING(Category)],
    [0, 0.3, 0, 2],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(zoneSpreadFactor),
    "SLIDER",
    [LSTRING(Setting_ZoneSpread), LSTRING(Setting_ZoneSpread_Desc)],
    [ELSTRING(medical,Category), LSTRING(Category)],
    [0, 1, 0.3, 2],
    1
] call CBA_fnc_addSetting;
