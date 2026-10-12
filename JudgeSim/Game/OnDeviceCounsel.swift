import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Apple Intelligence's on-device model (iOS 26 and later). Free, private, and offline,
/// but it has a small context window and its own content guardrails.
enum OnDeviceCounsel {

    enum Status: Equatable {
        case available
        case unavailable(String)
    }

    static var status: Status {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available:
                return .available
            case .unavailable(.deviceNotEligible):
                return .unavailable("This iPhone doesn't support Apple Intelligence.")
            case .unavailable(.appleIntelligenceNotEnabled):
                return .unavailable("Turn on Apple Intelligence in the Settings app.")
            case .unavailable(.modelNotReady):
                return .unavailable("Apple Intelligence is still downloading. Try again later.")
            case .unavailable:
                return .unavailable("Apple Intelligence isn't available right now.")
            }
        }
        #endif
        return .unavailable("Requires iOS 26 and Apple Intelligence.")
    }

    static var isAvailable: Bool { status == .available }

    enum Failure: LocalizedError {
        case unavailable(String), guardrail, tooLong, other(String)

        var errorDescription: String? {
            switch self {
            case .unavailable(let reason): return reason
            case .guardrail: return "Apple's on-device model declined that question."
            case .tooLong: return "The case file is too long for the on-device model."
            case .other(let message): return message
            }
        }
    }

    /// One answer from counsel. Recent exchanges are folded into the prompt to keep within the context window.
    static func reply(instructions: String, history: [(question: String, answer: String)], question: String) async throws -> CounselReply {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            guard case .available = status else {
                if case .unavailable(let reason) = status { throw Failure.unavailable(reason) }
                throw Failure.unavailable("Unavailable")
            }
            do {
                return try await generate(instructions: instructions, history: Array(history.suffix(3)), question: question)
            } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
                // Drop the conversation and trim the file, then try once more.
                do {
                    return try await generate(instructions: CounselBrief.clip(instructions, 6_000), history: [], question: question)
                } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
                    throw Failure.tooLong
                }
            } catch LanguageModelSession.GenerationError.guardrailViolation {
                throw Failure.guardrail
            } catch let error as Failure {
                throw error
            } catch {
                throw Failure.other(error.localizedDescription)
            }
        }
        #endif
        throw Failure.unavailable("Requires iOS 26 and Apple Intelligence.")
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    @Generable
    struct Answer {
        @Guide(description: "What counsel says aloud to the judge, one to three sentences, in first person.")
        var answer: String
        @Guide(description: "True only if this answer raises the ADDITIONAL FACTOR from the instructions.")
        var raisesFactor: Bool
    }

    @available(iOS 26.0, *)
    private static func generate(instructions: String, history: [(question: String, answer: String)], question: String) async throws -> CounselReply {
        let session = LanguageModelSession(instructions: instructions)
        var prompt = ""
        if !history.isEmpty {
            prompt += "Earlier in this bench conference:\n"
            for turn in history {
                prompt += "Judge: \(CounselBrief.clip(turn.question, 200))\nYou: \(CounselBrief.clip(turn.answer, 300))\n"
            }
            prompt += "\n"
        }
        prompt += "The judge now asks: \(question)"
        let response = try await session.respond(to: prompt, generating: Answer.self,
                                                 options: GenerationOptions(temperature: 0.7))
        let answer = response.content.answer.trimmingCharacters(in: .whitespacesAndNewlines)
        return CounselReply(answer: answer.isEmpty ? "Judge, give me a moment on that." : answer,
                            raisesFactor: response.content.raisesFactor)
    }
    #endif
}
