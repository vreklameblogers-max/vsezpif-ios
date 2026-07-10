import SwiftUI

struct AlertsView: View {
    @Environment(AppState.self) private var state
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if state.alerts.isEmpty {
                        emptyState
                    } else {
                        ForEach(state.alerts) { alert in
                            alertRow(alert)
                        }
                    }
                    channelsCard
                    DemoDataFootnote()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Theme.bgGradient)
            .scrollIndicators(.hidden)
            .navigationTitle("Алерты")
            .toolbarBackground(Theme.bg.opacity(0.85), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Haptics.tap()
                        showAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Theme.gold)
                    }
                }
            }
            .sheet(isPresented: $showAdd) { AddAlertSheet() }
        }
    }

    private func alertRow(_ alert: PriceAlert) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill((alert.condition == .above ? Theme.green : Theme.red).opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: alert.condition == .above ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(alert.condition == .above ? Theme.green : Theme.red)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(alert.fund.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.text)
                Text("Цена \(alert.condition.rawValue) \(Fmt.rub(alert.threshold))")
                    .font(.caption)
                    .foregroundStyle(Theme.muted)
            }
            Spacer()
            Toggle("", isOn: binding(for: alert))
                .labelsHidden()
                .tint(Theme.gold)
        }
        .glassCard(padding: 14)
    }

    private func binding(for alert: PriceAlert) -> Binding<Bool> {
        Binding(
            get: { state.alerts.first(where: { $0.id == alert.id })?.isOn ?? false },
            set: { newValue in
                Haptics.select()
                if let i = state.alerts.firstIndex(where: { $0.id == alert.id }) {
                    state.alerts[i].isOn = newValue
                }
            }
        )
    }

    private var channelsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Каналы уведомлений")
            channelRow(icon: "paperplane.fill", title: "Telegram", state: "Подключён", ok: true)
            channelRow(icon: "bell.fill", title: "Push", state: "Подключён", ok: true)
            channelRow(icon: "envelope.fill", title: "E-mail", state: "Не подключён", ok: false)
        }
        .glassCard()
    }

    private func channelRow(icon: String, title: String, state: String, ok: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(Theme.blue)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Theme.text)
            Spacer()
            Text(state)
                .font(.caption.weight(.medium))
                .foregroundStyle(ok ? Theme.green : Theme.muted)
        }
        .padding(.vertical, 2)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bell.slash")
                .font(.system(size: 36))
                .foregroundStyle(Theme.muted)
            Text("Алертов пока нет")
                .font(.subheadline)
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

// Лист добавления алерта
struct AddAlertSheet: View {
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var fund: Fund? = nil
    @State private var condition: PriceAlert.Condition = .above
    @State private var threshold: Double = 0

    var body: some View {
        NavigationStack {
            Form {
                Section("Фонд") {
                    Picker("Фонд", selection: $fund) {
                        Text("Выберите").tag(Fund?.none)
                        ForEach(state.funds) { f in
                            Text(f.name).tag(Fund?.some(f))
                        }
                    }
                    .onChange(of: fund) {
                        if let f = fund { threshold = f.price.rounded() }
                    }
                }
                Section("Условие") {
                    Picker("Направление", selection: $condition) {
                        Text("Выше").tag(PriceAlert.Condition.above)
                        Text("Ниже").tag(PriceAlert.Condition.below)
                    }
                    .pickerStyle(.segmented)
                    HStack {
                        Text("Цена")
                        Spacer()
                        TextField("0", value: $threshold, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .navigationTitle("Новый алерт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Создать") {
                        if let f = fund, threshold > 0 {
                            Haptics.success()
                            state.alerts.append(
                                PriceAlert(fund: f, condition: condition, threshold: threshold)
                            )
                            dismiss()
                        }
                    }
                    .disabled(fund == nil || threshold <= 0)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }
}
