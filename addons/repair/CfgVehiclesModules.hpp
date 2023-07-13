class ACE_Module;
class ACE_moduleRepairSettings: ACE_Module {
    scope = 1;
    displayName = CSTRING(moduleName);
    icon = QPATHTOF(ui\Icon_Module_Repair_ca.paa);
    category = "ACE_Logistics";
    function = QFUNC(moduleRepairSettings);
    functionPriority = 1;
    isGlobal = 1;
    isSingular = 1;
    isTriggerActivated = 0;
    author = ECSTRING(Common,ACETeam);
    class Arguments {
        class engineerSetting_Repair {
            displayName = CSTRING(engineerSetting_Repair_name);
            description = CSTRING(engineerSetting_Repair_description);
            typeName = "NUMBER";
            class values {
                class anyone { name = CSTRING(engineerSetting_anyone); value = 0; };
                class Engineer { name = CSTRING(engineerSetting_EngineerOnly); value = 1; default = 1; };
                class Advanced { name = CSTRING(engineerSetting_AdvancedOnly); value = 2; };
            };
        };
        class engineerSetting_Wheel {
            displayName = CSTRING(engineerSetting_Wheel_name);
            description = CSTRING(engineerSetting_Wheel_description);
            typeName = "NUMBER";
            class values {
                class anyone { name = CSTRING(engineerSetting_anyone); value = 0; default = 1; };
                class Engineer { name = CSTRING(engineerSetting_EngineerOnly); value = 1; };
                class Advanced { name = CSTRING(engineerSetting_AdvancedOnly); value = 2; };
            };
        };
        class repairDamageThreshold {
            displayName = CSTRING(repairDamageThreshold_name);
            description = CSTRING(repairDamageThreshold_description);
            typeName = "NUMBER";
            defaultValue = 0.6;
        };
        class repairDamageThreshold_Engineer {
            displayName = CSTRING(repairDamageThreshold_Engineer_name);
            description = CSTRING(repairDamageThreshold_Engineer_description);
            typeName = "NUMBER";
            defaultValue = 0.4;
        };
        class consumeItem_ToolKit {
            displayName = CSTRING(consumeItem_ToolKit_name);
            description = CSTRING(consumeItem_ToolKit_description);
            typeName = "NUMBER";
            class values {
                class keep { name = ECSTRING(common,No); value = 0; default = 1; };
                class remove { name = ECSTRING(common,Yes); value = 1; };
            };
        };
        class fullRepairLocation {
            displayName = CSTRING(fullRepairLocation);
            description = CSTRING(fullRepairLocation_description);
            typeName = "NUMBER";
            class values {
                class anywhere { name = CSTRING(useAnywhere); value = 0; };
                class vehicle { name = CSTRING(repairVehicleOnly); value = 1; };
                class facility { name = CSTRING(repairFacilityOnly); value = 2; default = 1; };
                class vehicleAndFacility { name = CSTRING(vehicleAndFacility); value = 3; };
                class disabled { name = ECSTRING(common,Disabled); value = 4;};
            };
        };
        class engineerSetting_fullRepair {
            displayName = CSTRING(engineerSetting_fullRepair_name);
            description = CSTRING(engineerSetting_fullRepair_description);
            typeName = "NUMBER";
            class values {
                class anyone { name = CSTRING(engineerSetting_anyone); value = 0; };
                class Engineer { name = CSTRING(engineerSetting_EngineerOnly); value = 1; };
                class Advanced { name = CSTRING(engineerSetting_AdvancedOnly); value = 2; default = 1;};
            };
        };
        class addSpareParts {
            displayName = CSTRING(addSpareParts_name);
            description = CSTRING(addSpareParts_description);
            typeName = "BOOL";
            defaultValue = 1;
        };
        class wheelRepairRequiredItems {
            displayName = CSTRING(WheelRepairRequiredItems_DisplayName);
            description = CSTRING(wheelRepairRequiredItems_description);
            typeName = "NUMBER";
            class values {
                class None { name = "None"; value = 0;  default = 1;};
                class ToolKit { name = "ToolKit"; value = 1; };
            };
        };
    };
    class ModuleDescription {
        description = CSTRING(moduleDescription);
        sync[] = {};
    };
};

class Module_F;
class ACE_moduleAssignEngineerRoles: Module_F {
    scope = 1;
    displayName = CSTRING(AssignEngineerRole_Module_DisplayName);
    icon = QPATHTOF(ui\Icon_Module_Repair_ca.paa);
    category = "ACE_Logistics";
    function = QFUNC(moduleAssignEngineer);
    functionPriority = 10;
    isGlobal = 2;
    isTriggerActivated = 0;
    isDisposable = 0;
    author = ECSTRING(common,ACETeam);
    class Arguments {
        class EnableList {
            displayName = CSTRING(EnableList_DisplayName);
            description = CSTRING(AssignEngineerRole_EnableList_Description);
            defaultValue = "";
            typeName = "STRING";
        };
        class role {
            displayName = CSTRING(AssignEngineerRole_role_DisplayName);
            description = CSTRING(AssignEngineerRole_role_Description);
            typeName = "NUMBER";
            class values {
                class none {
                    name = CSTRING(AssignEngineerRole_role_none);
                    value = 0;
                };
                class medic {
                    name = CSTRING(AssignEngineerRole_role_engineer);
                    value = 1;
                    default = 1;
                };
                class doctor {
                    name = CSTRING(AssignEngineerRole_role_advanced);
                    value = 2;
                };
            };
        };
    };
    class ModuleDescription {
        description = CSTRING(AssignEngineerRole_Module_Description);
        sync[] = {};
    };
};
class ACE_moduleAssignRepairVehicle: Module_F {
    scope = 1;
    displayName = CSTRING(AssignRepairVehicle_Module_DisplayName);
    icon = QPATHTOF(ui\Icon_Module_Repair_ca.paa);
    category = "ACE_Logistics";
    function = QFUNC(moduleAssignRepairVehicle);
    functionPriority = 10;
    isGlobal = 2;
    isTriggerActivated = 0;
    isDisposable = 0;
    author = ECSTRING(common,ACETeam);
    class Arguments {
        class EnableList {
            displayName = CSTRING(EnableList_DisplayName);
            description = CSTRING(AssignRepairVehicle_EnableList_Description);
            defaultValue = "";
            typeName = "STRING";
        };
        class role {
            displayName = CSTRING(AssignRepairVehicle_role_DisplayName);
            description = CSTRING(AssignRepairVehicle_role_Description);
            typeName = "NUMBER";
            class values {
                class none {
                    name = ECSTRING(common,No);
                    value = 0;
                };
                class isVehicle {
                    name = ECSTRING(common,Yes);
                    value = 1;
                    default = 1;
                };
            };
        };
    };
    class ModuleDescription {
        description = CSTRING(AssignRepairVehicle_Module_Description);
        sync[] = {};
    };
};
class ACE_moduleAssignRepairFacility: ACE_moduleAssignRepairVehicle {
    displayName = CSTRING(AssignRepairFacility_Module_DisplayName);
    function = QFUNC(moduleAssignRepairFacility);
    class Arguments {
        class EnableList {
            displayName = CSTRING(EnableList_DisplayName);
            description = CSTRING(AssignRepairFacility_EnableList_Description);
            defaultValue = "";
            typeName = "STRING";
        };
        class role {
            displayName = CSTRING(AssignRepairFacility_role_DisplayName);
            description = CSTRING(AssignRepairFacility_role_Description);
            typeName = "NUMBER";
            class values {
                class none {
                    name = ECSTRING(common,No);
                    value = 0;
                };
                class isFacility {
                    name = ECSTRING(common,Yes);
                    value = 1;
                    default = 1;
                };
            };
        };
    };
    class ModuleDescription {
        description = CSTRING(AssignRepairFacility_Module_Description);
        sync[] = {};
    };
};
class ACE_moduleAddSpareParts: Module_F {
    scope = 1;
    displayName = CSTRING(AddSpareParts_Module_DisplayName);
    icon = QPATHTOF(ui\Icon_Module_Repair_ca.paa);
    category = "ACE_Logistics";
    function = QFUNC(moduleAddSpareParts);
    functionPriority = 10;
    isGlobal = 0;
    isTriggerActivated = 0;
    isDisposable = 0;
    author = ECSTRING(common,ACETeam);
    class Arguments {
        class List {
            displayName = CSTRING(EnableList_DisplayName);
            description = CSTRING(AddSpareParts_List_Description);
            defaultValue = "";
            typeName = "STRING";
        };
        class Part {
            displayName = CSTRING(AddSpareParts_Part_DisplayName);
            description = CSTRING(AddSpareParts_Part_Description);
            typeName = "STRING";
            class values {
                class Wheel {
                    name = CSTRING(SpareWheel);
                    value = "ACE_Wheel";
                    default = 1;
                };
                class Track {
                    name = CSTRING(SpareTrack);
                    value = "ACE_Track";
                };
            };
        };
        class Amount {
            displayName = CSTRING(AddSpareParts_Amount_DisplayName);
            description = CSTRING(AddSpareParts_Amount_Description);
            typeName = "NUMBER";
            defaultValue = 1;
        };
    };
    class ModuleDescription {
        description = CSTRING(AddSpareParts_Module_Description);
        sync[] = {};
    };
};
