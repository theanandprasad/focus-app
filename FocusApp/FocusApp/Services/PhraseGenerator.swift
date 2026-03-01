import Foundation

struct PhraseGenerator {
    private let adjectives = [
        "purple", "golden", "ancient", "frozen", "silent", "bright",
        "crystal", "velvet", "hollow", "crimson", "gentle", "stormy",
        "dusty", "silver", "rustic", "cloudy", "fading", "vivid",
        "polished", "twisted", "broken", "floating", "hidden", "marble"
    ]

    private let nouns = [
        "elephant", "mountain", "lantern", "river", "castle", "garden",
        "feather", "compass", "window", "bridge", "mirror", "candle",
        "forest", "shadow", "temple", "harbor", "meadow", "violin",
        "dragon", "beacon", "pillar", "sparrow", "glacier", "diamond"
    ]

    private let verbs = [
        "danced", "whispered", "wandered", "gathered", "tumbled", "echoed",
        "flickered", "crumbled", "traveled", "sparkled", "scattered", "drifted",
        "climbed", "painted", "carried", "floated", "glowed", "rested",
        "shimmered", "twisted", "bloomed", "melted", "soared", "rippled"
    ]

    private let prepositions = [
        "beneath", "beyond", "through", "across", "beside", "between",
        "above", "around", "within", "under", "among", "against"
    ]

    private let numbers = [
        "two", "three", "four", "five", "six", "seven",
        "eight", "nine", "ten", "eleven", "twelve", "thirteen"
    ]

    private let timeWords = [
        "morning", "evening", "midnight", "sunrise", "sunset", "twilight",
        "yesterday", "tomorrow", "forever", "always", "briefly", "quietly"
    ]

    /// Generates a random 12-word phrase.
    func generate() -> String {
        let words: [String] = [
            "the",
            adjectives.randomElement()!,
            nouns.randomElement()!,
            verbs.randomElement()!,
            prepositions.randomElement()!,
            numbers.randomElement()!,
            adjectives.randomElement()!,
            nouns.randomElement()!,
            prepositions.randomElement()!,
            "the",
            adjectives.randomElement()!,
            timeWords.randomElement()!
        ]
        return words.joined(separator: " ")
    }
}
