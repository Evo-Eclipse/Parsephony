import Testing
import Foundation
@testable import Parsephony

struct ParsephonyTests {

    @Test func testMultilineCommentAndString() async throws {
        let xmlString = """
        <config>
            <comment>This is a multiline
        comment</comment>
            <message>Hello, World!</message>
        </config>
        """

        let expectedConfig = """
config:
    comment:
        [[This is a multiline
comment]]
    message:
        [[Hello, World!]]
"""

        try await testParsing(xmlString: xmlString, expectedConfig: expectedConfig)
    }

    @Test func testArraysAndConstants() async throws {
        let xmlString = """
        <config>
            <array>
                <value>1</value>
                <value>2</value>
                <value>3</value>
            </array>
            <constant name="pi" value="3.14"/>
            <useConstant>$pi$</useConstant>
        </config>
        """

        let expectedConfig = """
config:
    array:
        value:
            [[1]]
        value:
            [[2]]
        value:
            [[3]]
    constant:
        let name = [[pi]];
        let value = [[3.14]];
    useConstant:
        [[\\$pi\\$]]
"""

        try await testParsing(xmlString: xmlString, expectedConfig: expectedConfig)
    }

    @Test func testNestedElements() async throws {
        let xmlString = """
        <config>
            <settings>
                <resolution>
                    <width>1920</width>
                    <height>1080</height>
                </resolution>
            </settings>
        </config>
        """

        let expectedConfig = """
config:
    settings:
        resolution:
            width:
                [[1920]]
            height:
                [[1080]]
"""

        try await testParsing(xmlString: xmlString, expectedConfig: expectedConfig)
    }

    @Test func testNetworkConfiguration() async throws {
        let xmlString = """
        <networkConfig>
            <server>
                <address>192.168.1.1</address>
                <port>8080</port>
            </server>
            <clients>
                <client>192.168.1.2</client>
                <client>192.168.1.3</client>
            </clients>
        </networkConfig>
        """

        let expectedConfig = """
networkConfig:
    server:
        address:
            [[192.168.1.1]]
        port:
            [[8080]]
    clients:
        client:
            [[192.168.1.2]]
        client:
            [[192.168.1.3]]
"""

        try await testParsing(xmlString: xmlString, expectedConfig: expectedConfig)
    }

    @Test func testEducationalCourseOutline() async throws {
        let xmlString = """
        <course>
            <title>Introduction to Programming</title>
            <modules>
                <module>
                    <name>Variables and Types</name>
                    <lessons>
                        <lesson>Variables</lesson>
                        <lesson>Data Types</lesson>
                    </lessons>
                </module>
                <module>
                    <name>Control Structures</name>
                    <lessons>
                        <lesson>If Statements</lesson>
                        <lesson>Loops</lesson>
                    </lessons>
                </module>
            </modules>
        </course>
        """

        let expectedConfig = """
course:
    title:
        [[Introduction to Programming]]
    modules:
        module:
            name:
                [[Variables and Types]]
            lessons:
                lesson:
                    [[Variables]]
                lesson:
                    [[Data Types]]
        module:
            name:
                [[Control Structures]]
            lessons:
                lesson:
                    [[If Statements]]
                lesson:
                    [[Loops]]
"""

        try await testParsing(xmlString: xmlString, expectedConfig: expectedConfig)
    }

    @Test func testHardwareSpecifications() async throws {
        let xmlString = """
        <computer>
            <processor>Intel Core i7</processor>
            <memory>16GB</memory>
            <storage>
                <type>SSD</type>
                <capacity>512GB</capacity>
            </storage>
        </computer>
        """

        let expectedConfig = """
computer:
    processor:
        [[Intel Core i7]]
    memory:
        [[16GB]]
    storage:
        type:
            [[SSD]]
        capacity:
            [[512GB]]
"""

        try await testParsing(xmlString: xmlString, expectedConfig: expectedConfig)
    }

    // Helper function to test parsing and serialization
    func testParsing(xmlString: String, expectedConfig: String) async throws {
        guard let xmlData = xmlString.data(using: .utf8) else {
            throw TestError("Failed to convert XML string to Data")
        }

        let parser = XMLParser(data: xmlData)
        let configParser = ConfigParser()
        parser.delegate = configParser

        if !parser.parse() {
            throw TestError("Failed to parse XML: \(parser.parserError?.localizedDescription ?? "Unknown error")")
        }

        if !configParser.syntaxErrors.isEmpty {
            let errorMessages = configParser.syntaxErrors.joined(separator: "\n")
            throw TestError("Syntax Errors:\n\(errorMessages)")
        }

        guard let configText = configParser.getConfigText() else {
            throw TestError("No configuration text generated")
        }

        // Trim whitespaces and newlines for comparison
        let actualConfig = configText.trimmingCharacters(in: .whitespacesAndNewlines)
        let expectedConfigTrimmed = expectedConfig.trimmingCharacters(in: .whitespacesAndNewlines)

        #expect(actualConfig == expectedConfigTrimmed, "Expected configuration does not match actual configuration")
    }

    struct TestError: Error, CustomStringConvertible {
        let message: String
        var description: String { message }

        init(_ message: String) {
            self.message = message
        }
    }
}
