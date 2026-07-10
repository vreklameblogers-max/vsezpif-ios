import SwiftUI

@main
struct VsezpifApp: App {
    @State private var state = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(state)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @Environment(AppState.self) private var state
    @AppStorage("onboardingSeen") private var onboardingSeen = false
    @State private var splashDone = false

    var body: some View {
        ZStack {
            Theme.bgGradient.ignoresSafeArea()

            if !splashDone {
                SplashView()
                    .transition(.opacity)
            } else if !onboardingSeen {
                OnboardingView { onboardingSeen = true }
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading).combined(with: .opacity)))
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: splashDone)
        .animation(.easeInOut(duration: 0.45), value: onboardingSeen)
        .task {
            await state.load()
            try? await Task.sleep(for: .seconds(1.8))
            splashDone = true
        }
    }
}

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(Theme.bg).withAlphaComponent(0.85)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Фонды", systemImage: "building.columns.fill") }
            IndexesView()
                .tabItem { Label("Индексы", systemImage: "chart.line.uptrend.xyaxis") }
            ConstructorView()
                .tabItem { Label("Конструктор", systemImage: "slider.horizontal.3") }
            AlertsView()
                .tabItem { Label("Алерты", systemImage: "bell.badge.fill") }
            PortfolioView()
                .tabItem { Label("Кабинет", systemImage: "person.crop.circle.fill") }
        }
        .tint(Theme.gold)
    }
}
