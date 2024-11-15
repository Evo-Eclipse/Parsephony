import Foundation

// Check for arguments
guard CommandLine.arguments.count == 3 else {
    print("Usage: XMLToConfig <input.xml> <output.cfg>")
    exit(1)
}

let inputFilePath = CommandLine.arguments[1]
let outputFilePath = CommandLine.arguments[2]

// Read input XML file
guard let xmlData = FileManager.default.contents(atPath: inputFilePath) else {
    print("Error: Cannot read input file at \(inputFilePath)")
    exit(1)
}

// Initialize parser
let parser = XMLParser(data: xmlData)
let configParser = ConfigParser()
parser.delegate = configParser

// Parse XML
if !parser.parse() {
    print("Error: Parsing failed with error: \(parser.parserError?.localizedDescription ?? "Unknown error")")
    exit(1)
}

// Check for syntax errors
if !configParser.syntaxErrors.isEmpty {
    for error in configParser.syntaxErrors {
        print("Syntax Error: \(error)")
    }
    exit(1)
}

// Get the configuration text
if let configText = configParser.getConfigText() {
    // Write output file
    do {
        try configText.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
        print("Configuration file generated at \(outputFilePath)")
        print("Mathematical expressions evaluated: \(configParser.expressionCount)")
    } catch {
        print("Error: Failed to write output file: \(error.localizedDescription)")
        exit(1)
    }
} else {
    print("Error: No configuration data generated.")
    exit(1)
}
