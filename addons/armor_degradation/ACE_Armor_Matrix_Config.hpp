// Custom 3D Armor Matrix Configurations
// Mission makers and mod authors can define custom armor matrices here
// If not defined, the system will auto-generate based on armor protection values

/*
 * Matrix Structure (3x3x3):
 * Layer 0 = Front, Layer 1 = Middle, Layer 2 = Back
 * Row 0 = Upper, Row 1 = Middle, Row 2 = Lower
 * Col 0 = Left, Col 1 = Center, Col 2 = Right
 *
 * Each cell value represents the protection coefficient at that zone
 * Values range from 0.0 (no protection) to 1.0+ (enhanced protection)
 *
 * Example: A plate carrier might have higher protection in center-chest (1.0)
 * but lower on the sides (0.5) where only soft armor exists
 */

class ACE_Armor_Matrix_Config {
    /*
     * Example configuration for a plate carrier vest
     * Uncomment and modify for specific vests
     *
     * class V_PlateCarrier1_rgr {
     *     material = 6;  // MATERIAL_COMPOSITE
     *
     *     // Front layer - where the main plate is
     *     class Layer0 {
     *         row0[] = {0.6, 1.0, 0.6};  // Upper: sides weak, center strong
     *         row1[] = {0.5, 1.0, 0.5};  // Middle: main plate coverage
     *         row2[] = {0.4, 0.8, 0.4};  // Lower: reduced plate coverage
     *     };
     *     // Middle layer
     *     class Layer1 {
     *         row0[] = {0.4, 0.8, 0.4};
     *         row1[] = {0.3, 0.7, 0.3};
     *         row2[] = {0.3, 0.6, 0.3};
     *     };
     *     // Back layer
     *     class Layer2 {
     *         row0[] = {0.5, 0.9, 0.5};  // Back plate
     *         row1[] = {0.4, 0.8, 0.4};
     *         row2[] = {0.3, 0.6, 0.3};
     *     };
     * };
     */

    // Default template for auto-generation reference
    class Default {
        material = -1;  // Auto-detect from armor class

        // These are multipliers applied to auto-generated values
        // based on armor's base protection rating
        class Layer0 {
            row0[] = {0.7, 1.0, 0.7};
            row1[] = {0.6, 1.0, 0.6};
            row2[] = {0.5, 0.8, 0.5};
        };
        class Layer1 {
            row0[] = {0.5, 0.8, 0.5};
            row1[] = {0.4, 0.7, 0.4};
            row2[] = {0.4, 0.6, 0.4};
        };
        class Layer2 {
            row0[] = {0.6, 0.9, 0.6};
            row1[] = {0.5, 0.8, 0.5};
            row2[] = {0.4, 0.6, 0.4};
        };
    };

    // Headgear default template (2x2x2 matrix)
    class DefaultHeadgear {
        material = -1;

        class Layer0 {
            row0[] = {0.9, 0.9};
            row1[] = {0.7, 0.7};
        };
        class Layer1 {
            row0[] = {0.8, 0.8};
            row1[] = {0.6, 0.6};
        };
    };
};
