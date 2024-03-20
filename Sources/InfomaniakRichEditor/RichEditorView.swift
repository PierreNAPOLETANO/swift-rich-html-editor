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


import UIKit
import WebKit

public class RichEditorView: UIView {
    /// The text that the text view displays.
    public var text: String {
        get {
            return htmlContent
        }
        set {
            // TODO: Set HTML content here
        }
    }

    /// The editor view’s delegate.
    public weak var delegate: RichEditorViewDelegate?

    /// The current selection styled text of the editor.
    public private(set) var selectedTextAttributes = RETextAttributes()

    ///
    private(set) var webView: WKWebView!

    private var htmlContent = ""

    private var webViewBridge: WebViewBridgeManager!
    private var scriptMessageHandler: ScriptMessageHandler!

    override init(frame: CGRect) {
        super.init(frame: frame)

        scriptMessageHandler = ScriptMessageHandler()
        scriptMessageHandler.delegate = self

        setUpWebView()
        webViewBridge = WebViewBridgeManager(webView: webView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Format text

public extension RichEditorView {
    func bold() {
        applyStyle(.bold)
    }

    func italic() {
        applyStyle(.italic)
    }

    func underline() {
        applyStyle(.underline)
    }

    func strikethrough() {
        applyStyle(.strikethrough)
    }

    private func applyStyle(_ style: RETextFormat) {
        webViewBridge.applyFormat(style)
    }
}

// MARK: - WKWebView

public extension RichEditorView {
    func addInputAccessoryView(_ view: UIView) {
        webView.addInputAccessoryView(view)
    }

    private func setUpWebView() {
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])

        configureWebView()
        enableWebViewDebug()

        loadWebViewPage()
        loadScripts()
    }

    private func configureWebView() {
        if #available(iOS 14.0, *) {
            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        } else {
            webView.configuration.preferences.javaScriptEnabled = false
        }

        for messageHandler in ScriptMessageHandler.Handler.allCases {
            webView.configuration.userContentController.add(scriptMessageHandler, scriptMessage: messageHandler)
        }
    }

    private func loadScripts() {
        for script in REScript.allCases {
            webView.configuration.userContentController.addUserScript(
                named: script.name,
                injectionTime: script.injectionTime,
                forMainFrameOnly: true
            )
        }
    }

    private func loadWebViewPage() {
        guard let indexURL = Bundle.module.url(forResource: "index", withExtension: "html") else {
            return
        }

        let request = URLRequest(url: indexURL)
        webView.load(request)
    }

    private func enableWebViewDebug() {
        if #available(iOS 16.4, *) {
            #if DEBUG
            webView.isInspectable = true
            #endif
        }
    }
}

// MARK: - ScriptMessageHandlerDelegate

extension RichEditorView: ScriptMessageHandlerDelegate {
    func userDidType(_ text: String) {
        htmlContent = text
        delegate?.richEditorViewDidChange(self)
    }

    func selectionStateDidChange(_ selectedTextAttributes: RETextAttributes?) {
        guard let selectedTextAttributes else {
            return
        }

        self.selectedTextAttributes = selectedTextAttributes
        delegate?.richEditorView(self, didSelectedTextAttributesChanged: selectedTextAttributes)
    }
}
