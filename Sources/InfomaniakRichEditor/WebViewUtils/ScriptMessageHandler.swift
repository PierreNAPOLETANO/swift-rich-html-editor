//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.


import OSLog
import WebKit

protocol ScriptMessageHandlerDelegate: AnyObject {
    func editorDidLoad()
    func contentDidChange(_ text: String)
    func contentHeightDidChange(_ contentHeight: CGFloat)
    func selectedTextAttributesDidChange(_ selectedTextAttributes: RETextAttributes?)
    func selectionDidChange(_ selection: RESelection?)
}

final class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    enum Handler: String, CaseIterable {
        case editorDidLoad
        case contentDidChange
        case contentHeightDidChange
        case selectedTextAttributesDidChange
        case selectionDidChange
        case scriptLog
    }

    weak var delegate: ScriptMessageHandlerDelegate?

    private let logger = Logger(subsystem: "com.infomaniak.swift-rich-editor", category: "ScriptMessageHandler")

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let messageName = Handler(rawValue: message.name) else {
            return
        }

        switch messageName {
        case .editorDidLoad:
            editorDidLoad()
        case .contentDidChange:
            contentDidChange(message)
        case .contentHeightDidChange:
            contentHeightDidChange(message)
        case .selectedTextAttributesDidChange:
            selectedTextAttributesDidChange(message)
        case .selectionDidChange:
            selectionDidChange(message)
        case .scriptLog:
            scriptLog(message)
        }
    }

    private func editorDidLoad() {
        delegate?.editorDidLoad()
    }

    private func contentDidChange(_ message: WKScriptMessage) {
        guard let newContent = message.body as? String else {
            return
        }
        delegate?.contentDidChange(newContent)
    }

    private func contentHeightDidChange(_ message: WKScriptMessage) {
        guard let height = message.body as? CGFloat else {
            return
        }
        delegate?.contentHeightDidChange(height)
    }

    private func selectedTextAttributesDidChange(_ message: WKScriptMessage) {
        guard let json = message.body as? String, let data = json.data(using: .utf8) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            let selectedTextAttributes = try decoder.decode(RETextAttributes.self, from: data)

            delegate?.selectedTextAttributesDidChange(selectedTextAttributes)
        } catch {
            logger.error("Error while trying to decode RETextAttributes: \(error)")
            delegate?.selectedTextAttributesDidChange(nil)
        }
    }

    private func selectionDidChange(_ message: WKScriptMessage) {
        guard let json = message.body as? String, let data = json.data(using: .utf8) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            let selection = try decoder.decode(RESelection.self, from: data)

            delegate?.selectionDidChange(selection)
        } catch {
            logger.error("Error while trying to decode RESelection: \(error)")
            delegate?.selectionDidChange(nil)
        }

    }

    private func scriptLog(_ message: WKScriptMessage) {
        guard let log = message.body as? String else {
            return
        }
        logger.info("[ScriptLog] \(log)")
    }
}
