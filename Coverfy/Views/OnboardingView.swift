import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let body: String
}

struct OnboardingView: View {
    @AppStorage("onboardingDone") private var onboardingDone = false
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "doc.text.viewfinder", color: .coverfyBlue,
            title: "Escanea tu ticket",
            body: "Fotografía el ticket al comprar y Coverfy extrae la tienda y la fecha automáticamente."
        ),
        OnboardingPage(
            icon: "bell.badge", color: .coverfyTeal,
            title: "Te avisamos antes de que caduque",
            body: "Guardamos la garantía y te recordamos 30 y 7 días antes de que expire."
        ),
        OnboardingPage(
            icon: "doc.plaintext", color: .coverfyOrange,
            title: "Reclama si algo se rompe",
            body: "Si el producto falla, generamos el escrito de reclamación conforme a la garantía legal, listo para enviar."
        )
    ]

    var body: some View {
        let current = pages[min(page, pages.count - 1)]

        ZStack {
            LinearGradient(
                colors: [current.color, current.color.opacity(0.75)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button("Saltar") { onboardingDone = true }
                        .foregroundStyle(.white)
                        .padding()
                }

                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, p in
                        VStack(spacing: 24) {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.2))
                                    .frame(width: 140, height: 140)
                                Image(systemName: p.icon)
                                    .font(.system(size: 64))
                                    .foregroundStyle(.white)
                            }
                            Text(p.title)
                                .font(.title.bold())
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                            Text(p.body)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                Button {
                    if page < pages.count - 1 {
                        withAnimation { page += 1 }
                    } else {
                        onboardingDone = true
                    }
                } label: {
                    HStack {
                        Text(page < pages.count - 1 ? "Siguiente" : "Empezar")
                        if page == pages.count - 1 {
                            Image(systemName: "checkmark")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(current.color)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }
        }
    }
}
