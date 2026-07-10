import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("onboardingSeen") private var onboardingSeen = true
    @State private var faceID = true
    @State private var pushOn = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(Theme.goldGradient).frame(width: 52, height: 52)
                            Text("ИВ")
                                .font(.headline)
                                .foregroundStyle(Theme.bg)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Иван Воронин")
                                .font(.headline)
                                .foregroundStyle(Theme.text)
                            Text("Тариф Pro · до 12.2026")
                                .font(.caption)
                                .foregroundStyle(Theme.gold)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Theme.card)

                Section("Безопасность") {
                    Toggle(isOn: $faceID) {
                        Label("Вход по Face ID", systemImage: "faceid")
                    }
                    LabeledContent {
                        Text("Подключён").font(.caption).foregroundStyle(Theme.green)
                    } label: {
                        Label("Passkey", systemImage: "person.badge.key.fill")
                    }
                    LabeledContent {
                        Text("Включена").font(.caption).foregroundStyle(Theme.green)
                    } label: {
                        Label("2FA (TOTP)", systemImage: "lock.shield.fill")
                    }
                }
                .listRowBackground(Theme.card)

                Section("Уведомления") {
                    Toggle(isOn: $pushOn) {
                        Label("Push-уведомления", systemImage: "bell.badge.fill")
                    }
                    LabeledContent {
                        Text("@vsezpif").font(.caption).foregroundStyle(Theme.blue)
                    } label: {
                        Label("Telegram", systemImage: "paperplane.fill")
                    }
                }
                .listRowBackground(Theme.card)

                Section {
                    LabeledContent("Версия", value: "0.8.0 Showcase")
                    LabeledContent("Данные", value: "MOEX ISS (снимок)")
                    Link(destination: URL(string: "https://vsezpif.pages.dev")!) {
                        Label("Веб-версия", systemImage: "safari.fill")
                    }
                    Button {
                        onboardingSeen = false
                        dismiss()
                    } label: {
                        Label("Показать онбординг", systemImage: "arrow.counterclockwise")
                    }
                } header: {
                    Text("О приложении")
                } footer: {
                    Text("Демонстрационная версия. Котировки — снимок MOEX ISS; аналитика, портфель и алерты — демо-данные без подключения к серверу.")
                        .font(.caption2)
                }
                .listRowBackground(Theme.card)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.bgGradient)
            .tint(Theme.gold)
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
