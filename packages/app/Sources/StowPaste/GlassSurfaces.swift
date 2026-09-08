import AppKit
import SwiftUI

/// Bridges AppKit's behind-window material into SwiftUI. SwiftUI `Material`
/// only samples content from the app's own view hierarchy, while the floating
/// clipboard panel needs to blur the desktop and the app behind it.
struct NativeVisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var state: NSVisualEffectView.State

    init(
        material: NSVisualEffectView.Material = .popover,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        state: NSVisualEffectView.State = .active
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.state = state
    }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        configure(view)
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        configure(nsView)
    }

    private func configure(_ view: NSVisualEffectView) {
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        view.isEmphasized = false
    }
}

/// The large panel uses a standard macOS material. This keeps the content layer
/// calm while controls can opt into Liquid Glass on macOS 26 and later.
struct AdaptivePanelBackground: View {
    var tint: Color
    var cornerRadius: CGFloat = 18
    var material: NSVisualEffectView.Material = .popover

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
            if reduceTransparency {
                shape.fill(Color(nsColor: .windowBackgroundColor))
            } else {
                NativeVisualEffectView(material: material)
                    .clipShape(shape)
            }

            shape.fill(tint)

            if !reduceTransparency {
                shape.fill(
                    colorScheme == .dark
                        ? Color.black.opacity(0.08)
                        : Color.white.opacity(0.10)
                )
            }
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}

/// Uses Liquid Glass for the compact functional layer when available and a
/// standard material on older supported macOS releases.
struct AdaptiveGlassSurface: ViewModifier {
    var cornerRadius: CGFloat
    var tint: Color?

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @ViewBuilder
    func body(content: Content) -> some View {
        if reduceTransparency {
            content
                .background(
                    Color(nsColor: .controlBackgroundColor),
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
        } else if #available(macOS 26.0, *) {
            content.glassEffect(
                tint.map { Glass.regular.tint($0) } ?? Glass.regular,
                in: .rect(cornerRadius: cornerRadius)
            )
        } else {
            content.background(
                .thinMaterial,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
        }
    }
}

extension View {
    func adaptiveGlassSurface(cornerRadius: CGFloat, tint: Color? = nil) -> some View {
        modifier(AdaptiveGlassSurface(cornerRadius: cornerRadius, tint: tint))
    }
}
