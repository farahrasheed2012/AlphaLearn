import AVFoundation
import UIKit

// MARK: - Audio Service

/// Manages audio playback for letter pronunciation, sound effects, and feedback.
/// Uses AVSpeechSynthesizer for letter/word pronunciation (no audio files needed)
/// and system sounds for UI feedback.
class AudioService: ObservableObject {
    static let shared = AudioService()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {
        // Configure audio session for playback
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: - Speech

    /// Speak a letter name (e.g. "A")
    func speakLetter(_ letter: String) {
        speak("\(letter)", rate: 0.4)
    }

    /// Speak the phonetic sound of a letter (e.g. "ah" for A)
    func speakLetterSound(_ letter: String) {
        let phonetics: [String: String] = [
            "A": "ah", "B": "buh", "C": "kuh", "D": "duh", "E": "eh",
            "F": "fuh", "G": "guh", "H": "huh", "I": "ih", "J": "juh",
            "K": "kuh", "L": "luh", "M": "muh", "N": "nuh", "O": "oh",
            "P": "puh", "Q": "kwuh", "R": "ruh", "S": "sss", "T": "tuh",
            "U": "uh", "V": "vuh", "W": "wuh", "X": "ks", "Y": "yuh",
            "Z": "zz",
        ]
        let sound = phonetics[letter.uppercased()] ?? letter
        speak(sound, rate: 0.35)
    }

    /// Speak a word (e.g. "Apple")
    func speakWord(_ word: String) {
        speak(word, rate: 0.45)
    }

    /// Speak an instruction for the child
    func speakInstruction(_ text: String) {
        speak(text, rate: 0.48)
    }

    /// Core speech method
    private func speak(_ text: String, rate: Float) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.pitchMultiplier = 1.1 // Slightly higher pitch for kid-friendliness
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }

    // MARK: - Sound Effects

    /// Play a success chime
    func playSuccess() {
        AudioServicesPlaySystemSound(1025) // SMS received tone — cheerful
    }

    /// Play a gentle error / try-again sound
    func playTryAgain() {
        AudioServicesPlaySystemSound(1053) // Low tone
    }

    /// Play a tap/click sound
    func playTap() {
        AudioServicesPlaySystemSound(1104) // Keyboard click
    }

    /// Play a celebration fanfare
    func playCelebration() {
        AudioServicesPlaySystemSound(1026) // Payment success
    }

    /// Play a sparkle/magic sound
    func playSparkle() {
        AudioServicesPlaySystemSound(1057) // Tweet sent
    }

    /// Provide haptic feedback
    func hapticSuccess() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
    }

    func hapticError() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.error)
    }

    func hapticLight() {
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
    }
}
