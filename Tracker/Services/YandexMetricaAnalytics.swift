import YandexMobileMetrica

final class YandexMetricaAnalytics {
    
    private let apiKey = "f9111381-46d5-4cd4-9850-0a1b4682134e"
    
    static let shared = YandexMetricaAnalytics()
    
    private init() {}
    
    func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: apiKey) else { return }
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: String, params: [AnyHashable: Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
}
