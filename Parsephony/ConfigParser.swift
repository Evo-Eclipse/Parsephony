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
    
    func parserDidStartDocument(_ parser: XMLParser) {
        rootElement = nil
        elementStack = []
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
        
        // Attributes as constants
        for (key, value) in element.attributes {
            result += "\(indent)    let \(key) = [[\(value)]];\n"
        }
        
        // Element value
        if let value = element.value {
            let escapedValue = value.replacingOccurrences(of: "$", with: "\\$")
            result += "\(indent)    [[\(escapedValue)]]\n"
        }
        
        // Children
        for child in element.children {
            result += serialize(element: child, indentLevel: indentLevel + 1)
        }
        
        return result
    }
}
