import SwiftUI

extension View {
    /// Applies Liquid-Glass-style magnification to a selection highlight bar.
    ///
    /// Visual layers (back to front):
    ///   1. Left/right edge refractions — light bending at the glass rim
    ///   2. Convex lens surface highlight — the bright curved face of a thick glass slab,
    ///      brightest along the optical axis (top-center) and dimming toward the edges
    ///   3. Scale + shadow — the row "lifts" toward the viewer (magnification depth gap)
    ///   4. Spring animation — the glass slab glides smoothly as selection moves
    func selectionBarRefraction(when condition: Bool = true) -> some View {
        // ── Left-edge refraction ─────────────────────────────────────────
        overlay(alignment: .leading) {
            if condition {
                LinearGradient(
                    stops: [
                        .init(color: .white.opacity(0.45), location: 0.0),
                        .init(color: .white.opacity(0.15), location: 0.20),
                        .init(color: .clear,               location: 0.38)
                    ],
                    startPoint: .leading, endPoint: .trailing
                )
                .blendMode(.overlay)
                .allowsHitTesting(false)
            }
        }
        // ── Right-edge refraction ────────────────────────────────────────
        .overlay(alignment: .trailing) {
            if condition {
                LinearGradient(
                    stops: [
                        .init(color: .white.opacity(0.30), location: 0.0),
                        .init(color: .white.opacity(0.08), location: 0.18),
                        .init(color: .clear,               location: 0.32)
                    ],
                    startPoint: .trailing, endPoint: .leading
                )
                .blendMode(.overlay)
                .allowsHitTesting(false)
            }
        }
        // ── Convex lens surface — bright face of a thick biconvex glass slab ──
        // Real convex glass is brightest along the optical axis (top-center) and
        // dims as the surface curves away from the viewer toward the edges.
        .overlay {
            if condition {
                LinearGradient(
                    stops: [
                        .init(color: .white.opacity(0.42), location: 0.00),
                        .init(color: .white.opacity(0.14), location: 0.35),
                        .init(color: .clear,               location: 0.68)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .blendMode(.overlay)
                .allowsHitTesting(false)
            }
        }
        // ── Magnification: row scales up and lifts above its neighbors ───
        .scaleEffect(condition ? 1.09 : 1.0, anchor: .center)
        .shadow(color: .black.opacity(condition ? 0.20 : 0.0), radius: 3, x: 0, y: 1)
        .zIndex(condition ? 1.0 : 0.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.72), value: condition)
    }
}
