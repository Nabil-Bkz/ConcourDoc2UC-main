//
// Created by Wadÿe on 12/03/2023.
//

import Foundation

/** A Sweetener random codes generator, made by Wadÿe Khebbeb.

 SWCodeGenerator allows you to generate codes with a high level of customisability and safety, all while avoiding duplicates.

 All you need to do is create an instance of this class.

     let generator = SWCodeGenerator(length: 5)
     // Allows to generate 5-characters long, unique codes.
 
 Or you can override the default argument values to achieve a configuration of your liking:
 
     let generator = SWCodeGenerator(length 6, format: .alphabetical,
     textCase: .uppercase, uniqueCodes: false)
     // Allows to generate 6-characters long,
     // codes that contain only letters in uppercase,
     // and they don't have to be unique.

 For more info on customising your generator, please see ``Format`` and ``TextCase``.
 
 The unique codes generated can be used for verification, identity-checking, and so on. You can turn it off, if you do not care about or need duplicate codes.
 
 Then use either of the instance methods available to generate a code and store it into a string variable.

     let code = try generator.generate()
     // EKSTQZ

 The other instance method allows you to create unique codes, but in accordance with an already existing memory so that duplicates cannot be made.

 Imagining we have an array, holding already existing codes from a database or any data persistence layer:

     var alreadyExistingCodes = ["EKNWQX", "DFLPWK", ...]
     let code = try generator.generate(considering: &alreadyExistingCodes)
     // will print a code that will certainly not be identical
     // to the ones already existing inside the database,
     // all while updating the memory provided.

 Fore more info on instance methods, please see ``generate()`` and ``generate(considering:)``.
*/
public final class SWCodeGenerator {
    
    private let uniqueCodes: Bool
    private let length: Int8
    private let format: SWCodeGenerator.Format
    private var textCase: SWCodeGenerator.TextCase
    private var memory: Set<String>
    
    private lazy var maximumCapacity: Int = {
        return Int(truncating: pow(Decimal(format.translated.count), Int(length)) as NSNumber)
    }()
    
    /// Create and configure an instance of the Sweetener random code generator.
    /// - Parameters:
    ///    - length: The length (in characters) of the codes to generate.
    ///    - format: Defines what the codes should be made out of. Default is `.default`. See ``Format``.
    ///    - textCase: Describes how the generated codes would be cased. Default is `.uppercase`. See ``TextCase``.
    ///    - uniqueCodes: Tells whether the codes should be unique and no possible duplicates are allowed. Default is `true`.
    ///
    /// - Warning: If the `uniqueCodes` argument is set to `false`, then it will be systematically ignored when using ``generate(considering:)``, but will not be overridden by it.
    public init(
        length: Int8,
        format: SWCodeGenerator.Format = .default,
        textCase: SWCodeGenerator.TextCase = .uppercase,
        uniqueCodes: Bool = true
    ) {
        self.memory = []
        self.uniqueCodes = uniqueCodes
        self.length = length
        self.format = format
        self.textCase = textCase
    }
    
    /// Generate a random string code using the initialiser's configuration.
    /// - Returns: A string value.
    /// - Throws: An error of type ``GenerationError``.
    public func generate() throws -> String {
        try checkForBasicErrors()
        var randomValue: String = produce()
        if self.uniqueCodes {
            guard memory.count < maximumCapacity else {
                throw GenerationError.noMoreUniqueCodeCombinations
            }
            while memory.contains(randomValue) {
                randomValue = produce()
            }
            self.memory.insert(randomValue)
        }
        return randomValue
    }
    
    /// Generate a unique random string code using the initialiser's configuration, in accordance with an already existing, mutable memory to avoid duplicate codes.
    ///   - Parameters:
    ///     - memory: An array of strings (mainly codes) that the generator takes into account to avoid duplicate codes.
    ///   - Returns: A string value.
    ///   - Throws: An error of type ``GenerationError``.
    /// - Warning: This method systematically ignores the `uniqueCodes` argument when it's set to `false`, but does not override it.
    public func generate(considering memory: inout Set<String>) throws -> String {
        try checkForBasicErrors()
        var randomValue: String = produce()
        guard memory.count < maximumCapacity else {
            throw GenerationError.noMoreUniqueCodeCombinations
        }
        while memory.contains(randomValue) {
            randomValue = produce()
        }
        memory.insert(randomValue)
        return randomValue
    }
    
    private func produce() -> String {
        var produced = String((0..<length).map { _ in format.translated.randomElement()! })
        textCase.apply(to: &produced)
        return produced
    }
    
    private func checkForBasicErrors() throws {
        guard self.length > 0 else {
            throw GenerationError.invalidLength(self.length)
        }
        
        guard !self.format.translated.containsWhiteSpacesAndNewLines else {
            throw GenerationError.whiteSpacesAndNewLines
        }
        
        guard self.format.translated.hasUniqueCharacters else {
            throw GenerationError.duplicateBaseCharacters
        }
        
        guard (self.format.translated.count >= 5) else {
            throw GenerationError.smallFormat(self.format.translated)
        }
    }
    
    /// The available options for formatting the codes.
    ///
    /// Considering we want to generate **5-characters long codes** with **uppercased** characters, here is how many **unique** codes the generator can make, depending on the `format` configuration chosen:
    ///   - `default`: up to 33 million codes.
    ///   - `alphabetical`: up to 6 million codes.
    ///   - `numerical`: up to 59 thousand codes.
    ///   - `custom`: 3,125 codes minimum.
    ///
    /// With the parameter `textCase` set to its default value (`hybridcased`), the number of possible codes becomes astronomically bigger.
    ///
    ///  - Note: For the purpose of readability, some letters and numbers are omitted, as the human eyes often confuse them (such as capital "I" with lowercase "L", zero with the letter "O"). You can always include them in a custom format of characters if you'd like, by using `custom()`.
    public enum Format {
        
        /// The codes may contain both letters and numbers. This option is the most productive.
        case `default`
        
        /// The codes may contain numerical digits only, from 1 to 9.
        case numerical
        
        /// The codes may contain alphabetical letters only, from A to Z.
        case alphabetical
        
        /// The codes should be made using only the custom base characters provided. This option might be the most productive.
        /// - Warning: Providing a very small set of characters is not recommended, or not allowed, as it may narrow down the generation of unique codes too much.
        /// - Warning: Use of punctuation is highly discouraged as it may confuse the human eyes.
        case custom(String)
        
        var translated: String {
            switch self {
            case .default:
                return "abcdefghjkmnpqrstuvwxyz123456789"
            case .numerical:
                return "123456789"
            case .alphabetical:
                return "abcdefghjkmnpqrstuvwxyz"
            case .custom(let characters):
                return characters
            }
        }
    }
    
    /// The available options for applying a case to the generated codes.
    public enum TextCase {
        
        /// The letters contained in the generated codes will be uppercased.
        case uppercase
        
        /// The letters contained in the generated codes will be lowercased.
        case lowercase
        
        /// The letters contained in the generated codes will be randomly cased. Each letter can either be uppercased or lowercased. This option might the most reliable.
        case hybrid
        
        func apply(to input: inout String) {
            switch self {
            case .uppercase:
                input = input.uppercased()
            case .lowercase:
                input = input.lowercased()
            case .hybrid:
                input = input.randomlyCased()
            }
        }
    }
    
    /// The errors that can be thrown during a code generation.
    public enum GenerationError: Error, CustomStringConvertible {
        
        /// Thrown when an invalid length is provided.
        case invalidLength(Int8)
        
        /// Thrown when the provided custom characters are not enough.
        case smallFormat(String)
        
        /// Thrown when the base characters contain white spaces and/or new lines.
        case whiteSpacesAndNewLines
        
        /// Thrown when the base characters in custom format are not all unique.
        case duplicateBaseCharacters
        
        /// Thrown when no more unique codes can be generated using the provided configuration.
        case noMoreUniqueCodeCombinations
        
        var detailedDescription: String {
            switch self {
            case .invalidLength(let length):
                return "Invalid code length provided to initialiser (\(length)). Code length must be a strictly positive integer."
            case .smallFormat(let string):
                return "Rejected use of small custom format (\"\(string)\", which is only \(string.count) characters long). Custom format must be at least 5 characters long."
            case .whiteSpacesAndNewLines:
                return "Rejected use of particular characters in custom format. Special characters such as white spaces and new lines are not allowed."
            case .duplicateBaseCharacters:
                return "Found one or more duplicate characters in custom format. Duplicate characters are not allowed."
            case .noMoreUniqueCodeCombinations:
                return "Could not generate a new unique code using the configuration provided."
            }
        }
        
        public var description: String {
            return self.detailedDescription
        }
        
    }
}


extension String {
    /// Returns a randomly cased version of this string. Each letter can either be lowercased or uppercased.
    public func randomlyCased() -> Self {
        return self.map {
            if Int.random(in: 0...1) == 0 {
                return String($0).lowercased()
            }
            return String($0).uppercased()
        }.joined(separator: "")
    }
    
    /// Returns whether the string contains white spaces.
    public var containsWhiteSpaces: Bool {
        return self.rangeOfCharacter(from: .whitespaces) != nil
    }
    
    /// Returns whether the string contains white spaces and/or new lines.
    public var containsWhiteSpacesAndNewLines: Bool {
        return self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil
    }
    
    /// Returns whether all the characters of the string are unique.
    public var hasUniqueCharacters: Bool {
        var dict: [Character: Int] = [:]
        for (index, char) in self.enumerated() {
            if dict[char] != nil { return false }
            dict[char] = index
        }
        return true
    }
}
