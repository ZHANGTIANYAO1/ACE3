// Core matrix operations
PREP(initializeArmorMatrix);
PREP(createEmptyMatrix);
PREP(getMatrixValue);
PREP(setMatrixValue);
PREP(matrixMultiply);
PREP(matrixAdd);
PREP(matrixScale);
PREP(flattenMatrix);
PREP(unflattenMatrix);

// Armor degradation logic
PREP(applyDegradation);
PREP(calculateDegradation);
PREP(updateDegradation);
PREP(getDegradationFactor);
PREP(getMaterialDegradationRate);

// Hit and damage processing
PREP(handleWoundReceived);
PREP(processHit);
PREP(getHitZone);
PREP(calculateEffectiveArmor);

// Armor state management
PREP(getArmorState);
PREP(setArmorState);
PREP(getArmorIntegrity);
PREP(resetArmorState);

// Equipment handlers
PREP(handleLoadoutChange);
PREP(getArmorMaterial);
PREP(getArmorFromEquipment);

// Repair and replacement
PREP(repairArmor);
PREP(replaceArmor);
PREP(canRepairArmor);

// Utility functions
PREP(debugDrawMatrix);
PREP(getMatrixStats);
PREP(exportArmorState);
PREP(importArmorState);

// Parallel processing helpers (optimized operations)
PREP(batchProcessMatrix);
PREP(parallelMatrixOp);
