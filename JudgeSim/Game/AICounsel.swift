import Foundation
import Security

// MARK: - Settings

/// Which Claude model answers free-form questions to counsel.
enum CounselModel: String, CaseIterable, Identifiable {
    case opus = "claude-opus-5-5"
    case sonnet = "claude-sonnet-5-5"
    case haiku = "claude-haiku-5-5"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .opus: return "Claude Opus 5.5"
        case .sonnet: return "Claude Sonnet 5.5"
        case .haiku: return "Claude Haiku 5.5"
        }
    }

    var detail: String {
        switch self {
        case .opus: return "Sharpest lawyers. About 1–2¢ per question."
        case .sonnet: return "Fast and sharp. Under 1¢ per question."
        case .haiku: return "Fastest and cheapest. A fraction of a cent per question."
        }
    }

    /// Server-side refusal fallback is available for Opus 5.5 and Sonnet 5.5 on the Claude API.
    var supportsFallback: Bool { self != .haiku }
}

/// The player's own Claude API key (kept in the Keychain) and model choice.
final class AISettings: ObservableObject {
    static let shared = AISettings()

    private static let keychainAccount = "judgesim.anthropic.apikey"
    private static let modelKey = "JudgeSim.counselModel"

    @Published private(set) var hasKey: Bool
    @Published var model: CounselModel {
        didSet { UserDefaults.standard.set(model.rawValue, forKey: Self.modelKey) }
    }

    private init() {
        hasKey = Keychain.read(Self.keychainAccount) != nil
        model = CounselModel(rawValue: UserDefaults.standard.string(forKey: Self.modelKey) ?? "") ?? .opus
    }

    var apiKey: String? { Keychain.read(Self.keychainAccount) }

    func saveKey(_ key: String) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            Keychain.delete(Self.keychainAccount)
        } else {
            Keychain.write(trimmed, account: Self.keychainAccount)
        }
        hasKey = Keychain.read(Self.keychainAccount) != nil
    }

    func removeKey() {
        Keychain.delete(Self.keychainAccount)
        hasKey = false
    }
}

enum Keychain {
    static func write(_ value: String, account: String) {
        delete(account)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData as String: Data(value.utf8)
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    static func read(_ account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(_ account: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: account]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Claude API (raw HTTP; there is no official Swift SDK)

struct CounselReply {
    let answer: String
    let raisesFactor: Bool
}

enum ClaudeError: LocalizedError {
    case noKey, refusal, http(Int, String), malformed

    var errorDescription: String? {
        switch self {
        case .noKey: return "No API key. Add one in Settings."
        case .refusal: return "Claude declined to answer that one."
        case .http(let code, let message): return code == 401 ? "The API key was rejected (401). Check it in Settings." : "API error \(code): \(message)"
        case .malformed: return "Couldn't read Claude's reply."
        }
    }
}

enum ClaudeClient {
    private static let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!

    /// One turn of a bench conference. `history` alternates judge question / counsel answer, oldest first.
    static func counselReply(system: String, history: [(question: String, answer: String)], question: String,
                             settings: AISettings = .shared) async throws -> CounselReply {
        guard let key = settings.apiKey else { throw ClaudeError.noKey }
        let model = settings.model

        var messages: [[String: Any]] = []
        for turn in history {
            messages.append(["role": "user", "content": turn.question])
            messages.append(["role": "assistant", "content": turn.answer])
        }
        messages.append(["role": "user", "content": question])

        let schema: [String: Any] = [
            "type": "object",
            "properties": [
                "answer": ["type": "string", "description": "What counsel says aloud to the judge."],
                "raises_factor": ["type": "boolean", "description": "True only if this answer puts forward the additional factor described in the instructions."]
            ],
            "required": ["answer", "raises_factor"],
            "additionalProperties": false
        ]
        var body: [String: Any] = [
            "model": model.rawValue,
            "max_tokens": 4000,
            "system": [["type": "text", "text": system, "cache_control": ["type": "ephemeral"]]],
            "messages": messages,
            "output_config": [
                "effort": "low",
                "format": ["type": "json_schema", "schema": schema]
            ]
        ]
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 90
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        if model.supportsFallback {
            body["fallbacks"] = "default"
            request.setValue("server-side-fallback-2026-07-01", forHTTPHeaderField: "anthropic-beta")
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw ClaudeError.malformed }
        guard status == 200 else {
            let message = ((json["error"] as? [String: Any])?["message"] as? String) ?? "Unknown error"
            throw ClaudeError.http(status, message)
        }
        if json["stop_reason"] as? String == "refusal" { throw ClaudeError.refusal }

        let blocks = json["content"] as? [[String: Any]] ?? []
        let text = blocks.filter { $0["type"] as? String == "text" }.compactMap { $0["text"] as? String }.joined()
        if let parsed = try? JSONSerialization.jsonObject(with: Data(text.utf8)) as? [String: Any],
           let answer = parsed["answer"] as? String {
            return CounselReply(answer: answer, raisesFactor: parsed["raises_factor"] as? Bool ?? false)
        }
        guard !text.isEmpty else { throw ClaudeError.malformed }
        return CounselReply(answer: text, raisesFactor: false)
    }

    /// A tiny request to confirm the key works.
    static func test(settings: AISettings = .shared) async throws {
        _ = try await counselReply(system: "You are a courtroom clerk. Reply briefly.", history: [],
                                   question: "Say: Ready, Judge.", settings: settings)
    }
}

// MARK: - Offline answers

/// Without an API key, a typed question is matched against what counsel can speak to in the case file.
enum OfflineCounsel {
    private static let stopWords: Set<String> = ["the", "a", "an", "is", "are", "was", "were", "what", "why", "how", "do", "does",
                                                  "did", "you", "your", "to", "of", "in", "on", "for", "and", "or", "about",
                                                  "this", "that", "it", "i", "me", "my", "can", "could", "would", "should",
                                                  "tell", "with", "any", "there", "be", "has", "have", "judge", "counsel", "s"]

    private static let synonyms: [String: String] = [
        "deal": "plea", "offer": "plea", "bargain": "plea", "jail": "custody", "bond": "custody", "locked": "custody",
        "victim": "victim", "family": "victim", "money": "pay", "afford": "pay", "fees": "pay", "costs": "pay",
        "drugs": "treatment", "addiction": "treatment", "sober": "treatment", "mental": "treatment",
        "job": "plan", "work": "plan", "employed": "plan", "testify": "testify", "stand": "testify",
        "record": "priors", "prior": "priors", "history": "priors", "sentence": "recommend", "punishment": "recommend",
        "want": "recommend", "asking": "recommend", "evidence": "exhibit", "video": "exhibit", "dna": "exhibit",
        "search": "motion", "suppress": "motion", "miranda": "motion", "statement": "exhibit"
    ]

    private static func tokens(_ text: String) -> Set<String> {
        let words = text.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { $0.count > 1 && !stopWords.contains($0) }
        return Set(words.flatMap { [$0, synonyms[$0] ?? $0] })
    }

    static func answer(_ question: String, from options: [CounselQuestion], style: CounselStyle) -> (String, CounselReveal?) {
        let asked = tokens(question)
        let scored = options.map { option -> (CounselQuestion, Int) in
            let target = tokens(option.question + " " + option.id.replacingOccurrences(of: ".", with: " "))
            return (option, asked.intersection(target).count)
        }
        if let best = scored.max(by: { $0.1 < $1.1 }), best.1 > 0 {
            return (best.0.answer, best.0.reveal)
        }
        return (style.opener + "I'm not sure I follow what the court is asking. Could you put it another way?", nil)
    }
}
