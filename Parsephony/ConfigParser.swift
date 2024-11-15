import Foundation

// Define a configuration element
struct ConfigElement {
    var name: String
    var value: String?
    var attributes: [String: String]
    var children: [ConfigElement]
}

// ConfigParser class
class ConfigParser: NSObject, XMLParserDelegate {
    var rootElement: ConfigElement?
    var elementStack: [ConfigElement] = []
    var syntaxErrors: [String] = []
    
    // Accumulate characters between XML tags
    var currentCharacters: String = ""
    
    // Dictionary to store constants
    var constants: [String: Double] = [:]
    
    // Counter for mathematical expressions evaluated
    var expressionCount: Int = 0
    
    func parserDidStartDocument(_ parser: XMLParser) {
        rootElement = nil
        elementStack = []
        constants = [:]
        expressionCount = 0
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        // Create a new ConfigElement and push onto the stack
        let newElement = ConfigElement(name: elementName, value: nil, attributes: attributeDict, children: [])
        elementStack.append(newElement)
        currentCharacters = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentCharacters += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        guard var completedElement = elementStack.popLast() else {
            syntaxErrors.append("Unexpected end of element: \(elementName)")
            return
        }
        
        // Trim and check if there's any text content
        let trimmedCharacters = currentCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedCharacters.isEmpty {
            // Set the element value as the trimmed string
            completedElement.value = trimmedCharacters
        }
        
        // Reset currentCharacters
        currentCharacters = ""
        
        // If the element is a constant, store it in the constants dictionary
        if completedElement.name == "constant" {
            if let name = completedElement.attributes["name"],
               let valueStr = completedElement.attributes["value"],
               let value = Double(valueStr) {
                constants[name] = value
            }
        }
        
        // Add the completed element to its parent's children or set as root
        if var parentElement = elementStack.last {
            parentElement.children.append(completedElement)
            elementStack[elementStack.count - 1] = parentElement
        } else {
            rootElement = completedElement
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        syntaxErrors.append("Parse error: \(parseError.localizedDescription)")
    }
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        syntaxErrors.append("Validation error: \(validationError.localizedDescription)")
    }
    
    // Generate configuration text from the rootElement
    func getConfigText() -> String? {
        guard let rootElement = rootElement else {
            return nil
        }
        
        // Use a helper function to generate the text
        return serialize(element: rootElement, indentLevel: 0)
    }
    
    private func serialize(element: ConfigElement, indentLevel: Int) -> String {
        var result = ""
        let indent = String(repeating: "    ", count: indentLevel)
        
        // Element name
        result += "\(indent)\(element.name):\n"
        
        // Sort attributes alphabetically for consistent ordering
        let sortedAttributes = element.attributes.sorted { $0.key < $1.key }
        
        // Attributes as constants with expression evaluation
        for (key, value) in sortedAttributes {
            let evaluatedValue = evaluateExpressions(in: value)
            result += "\(indent)    let \(key) = [[\(evaluatedValue)]];\n"
        }
        
        // Element value with expression evaluation
        if let value = element.value {
            let evaluatedValue = evaluateExpressions(in: value)
            result += "\(indent)    [[\(evaluatedValue)]]\n"
        }
        
        // Children
        for child in element.children {
            result += serialize(element: child, indentLevel: indentLevel + 1)
        }
        
        return result
    }
    
    // Function to evaluate expressions enclosed in dollar signs
    private func evaluateExpressions(in value: String) -> String {
        var result = value
        let pattern = "\\$(.*?)\\$"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return result.replacingOccurrences(of: "$", with: "\\$")
        }
        
        let matches = regex.matches(in: value, options: [], range: NSRange(location: 0, length: value.utf16.count))
        
        // Process matches in reverse to avoid range issues during replacement
        for match in matches.reversed() {
            if match.numberOfRanges >= 2, let range = Range(match.range(at: 1), in: value) {
                let expressionString = String(value[range])
                if let evaluated = evaluateExpression(expressionString) {
                    expressionCount += 1
                    // Replace the entire "$...$" with the evaluated value
                    if let fullRange = Range(match.range(at: 0), in: result) {
                        result.replaceSubrange(fullRange, with: "\(evaluated)")
                    }
                }
            }
        }
        
        // Escape any remaining dollar signs
        result = result.replacingOccurrences(of: "$", with: "\\$")
        
        return result
    }
    
    // Function to evaluate a single mathematical expression
    private func evaluateExpression(_ expression: String) -> String? {
        var expr = expression
        
        // Replace constants in the expression with their values
        for (name, value) in constants {
            // Use word boundaries to avoid partial replacements
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: name))\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                expr = regex.stringByReplacingMatches(in: expr, options: [], range: NSRange(location: 0, length: expr.utf16.count), withTemplate: "\(value)")
            }
        }
        
        // Use NSExpression to evaluate the mathematical expression
        let expressionToEvaluate = NSExpression(format: expr)
        if let result = expressionToEvaluate.expressionValue(with: nil, context: nil) as? NSNumber {
            let doubleValue = result.doubleValue
            // Check if the double value is a whole number
            if doubleValue == floor(doubleValue) {
                return String(format: "%.0f", doubleValue)
            } else {
                return String(doubleValue)
            }
        }
        
        // If evaluation fails, return nil
        return nil
    }
}
