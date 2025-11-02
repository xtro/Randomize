import Foundation

extension RandomizationStrategy where Value == String {
    public static func word(characters: Int = 10) -> Self {
        Self {
            String.randomWord(characters)
        }
    }
    public static func words(count: Range<Int> = 3..<10, character: Range<Int> = 3..<10, capitalizedFirst: Bool = true) -> Self {
        Self {
            String.randomWords(count: count, character: character, capitalizedFirst: capitalizedFirst)
        }
    }
    public static func sentence(words: Range<Int> = 3..<10, character: Range<Int> = 3..<10) -> Self {
        Self {
            String.randomSentence(words: words, character: character)
        }
    }
    public static func paragraph(sentences: Range<Int>, words: Range<Int>, character: Range<Int> = 3..<10) -> Self {
        Self {
            String.randomParagraph(sentences: sentences, words: words, character: character)
        }
    }
    public static func text(paragraphs: Range<Int> = 1..<3, sentences: Range<Int> = 2..<4, words: Range<Int> = 3..<10, character: Range<Int> = 3..<10) -> Self {
        Self {
            String.randomText(paragraphs: paragraphs, sentences: sentences, words: words, character: character)
        }
    }
    
    public static func year(_ range: Range<Int> = 2010..<2025) -> Self {
        Self {
            "\(range.randomElement()!)"
        }
    }
    
    public static func day(_ range: Range<Int> = 1..<28) -> Self {
        Self {
            "\(range.randomElement()!)"
        }
    }
    
    public static var time: Self {
        Self {
            let hour = (0..<24).randomElement()!
            let minute = (0..<60).randomElement()!
            return "\(hour):\(minute)"
        }
    }
    
    public static func month(_ range: Range<Int> = 1..<12) -> Self {
        Self {
            let monthIndex = range.randomElement()!
            var comps = DateComponents()
            comps.year = 2000
            comps.month = monthIndex
            comps.day = 1
            if let date = Calendar.current.date(from: comps) {
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateFormat = "LLL" // localized short month, e.g., Jan, Feb, Máj, Szept
                return formatter.string(from: date)
            }
            return "\(monthIndex)".capitalized
        }
    }
}

private extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }
    static func randomText(paragraphs: Range<Int>, sentences: Range<Int>, words: Range<Int>, character: Range<Int>) -> String {
        paragraphs.randomElement()!.instance(
            randomParagraph(sentences: sentences, words: words, character: character)
        ).joined(separator: "\n")
    }
    
    static func randomParagraph(sentences: Range<Int>, words: Range<Int>, character: Range<Int>) -> String {
        sentences.randomElement()!.instance(
            randomSentence(words: words, character: character)
        ).joined(separator: " ")
    }
    
    static func randomSentence(words: Range<Int>, character: Range<Int>) -> String {
        let periods = [".", "!", "?"]
        return randomWords(count: words, character: character, capitalizedFirst: true) +
        periods[Int.random(in: 0 ..< periods.count)]
    }
    
    static func randomWords(count: Range<Int>, character: Range<Int>, capitalizedFirst: Bool = true) -> String {
        let words = (count.randomElement()! - 1).instance(
            randomWord(character.randomElement()!)
        ).joined(separator: " ")
        if capitalizedFirst {
            return words.capitalizingFirstLetter()
        }
        return words
    }
    static func randomWord(_ wordLength: Int = 6) -> String {
        let kCons = 1
        let kVows = 2
        
        var cons: [String] = [
            // single consonants. Beware of Q, it"s often awkward in words
            "b", "c", "d", "f", "g", "h", "j", "k", "l", "m",
            "n", "p", "r", "s", "t", "v", "w", "x", "z",
            // possible combinations excluding those which cannot start a word
            "pt", "gl", "gr", "ch", "ph", "ps", "sh", "st", "th", "wh",
        ]
        
        // consonant combinations that cannot start a word
        let cons_cant_start: [String] = [
            "ck", "cm",
            "dr", "ds",
            "ft",
            "gh", "gn",
            "kr", "ks",
            "ls", "lt", "lr",
            "mp", "mt", "ms",
            "ng", "ns",
            "rd", "rg", "rs", "rt",
            "ss",
            "ts", "tch",
        ]
        
        let vows: [String] = [
            // single vowels
            "a", "e", "i", "o", "u", "y",
            // vowel combinations your language allows
            "ee", "oa", "oo",
        ]
        
        // start by vowel or consonant ?
        var current = (Int(arc4random_uniform(2)) == 1 ? kCons : kVows)
        
        var word = ""
        while word.count < wordLength {
            // After first letter, use all consonant combos
            if word.count == 2 {
                cons = cons + cons_cant_start
            }
            
            // random sign from either $cons or $vows
            var rnd = ""
            var index: Int
            if current == kCons {
                index = Int(arc4random_uniform(UInt32(cons.count)))
                rnd = cons[index]
            } else if current == kVows {
                index = Int(arc4random_uniform(UInt32(vows.count)))
                rnd = vows[index]
            }
            
            // check if random sign fits in word length
            let tempWord = "\(word)\(rnd)"
            if tempWord.count <= wordLength {
                word = "\(word)\(rnd)"
                // alternate sounds
                current = (current == kCons) ? kVows : kCons
            }
        }
        
        return word
    }
}
private extension Int {
    func instance<Type>(_ of: @autoclosure () -> Type) -> [Type] {
        (0 ... self).map { _ in
            of()
        }
    }
}
