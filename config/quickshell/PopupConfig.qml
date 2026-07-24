pragma Singleton
import QtQuick

QtObject {
    id: root

    // ===========================================
    // ANIMATION CURVES (Material Design 3 style)
    // ===========================================
    // These bezier curves create expressive, fluid animations

    // Emphasized - for important, attention-grabbing animations
    readonly property var curveEmphasized: [0.05, 0, 0.133, 0.06, 0.166, 0.4, 0.208, 0.82, 0.25, 1, 1, 1]

    // Emphasized accelerate - for exits
    readonly property var curveEmphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]

    // Emphasized decelerate - for entrances
    readonly property var curveEmphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]

    // Standard - for most animations
    readonly property var curveStandard: [0.2, 0, 0, 1, 1, 1]

    // Expressive fast spatial - bouncy, playful
    readonly property var curveExpressiveFast: [0.42, 1.67, 0.21, 0.9, 1, 1]

    // Expressive default spatial - smooth with overshoot
    readonly property var curveExpressiveDefault: [0.38, 1.21, 0.22, 1, 1, 1]

    // ===========================================
    // ANIMATION DURATIONS
    // ===========================================
    readonly property int durationSmall: 150      // Quick micro-interactions
    readonly property int durationNormal: 250     // Standard animations
    readonly property int durationMedium: 350     // Emphasized animations
    readonly property int durationLarge: 500      // Complex/large animations

    // ===========================================
    // POPUP SPECIFIC TIMINGS
    // ===========================================
    readonly property int popupExpandDuration: 280    // Wrapper expansion
    readonly property int popupContentDuration: 200   // Content fade/scale
    readonly property int popupContentDelay: 50       // Delay before content animates

    // ===========================================
    // VISUAL PROPERTIES
    // ===========================================
    // Scale for content entrance
    readonly property real contentScaleStart: 0.85

    // Shadow settings
    readonly property bool shadowEnabled: true
    readonly property int shadowBlur: 24
    readonly property int shadowSpread: 6
    readonly property color shadowColor: "#60000000"
    readonly property int shadowOffsetY: 8

    // Blur settings (backdrop)
    readonly property bool blurEnabled: false  // Set to true if compositor supports
    readonly property real blurAmount: 0.3
}
