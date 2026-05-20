//
//  ContentView.swift
//  JotApp
//
//  Created by Kat Canavan on 8/21/23.
//

import SwiftUI
import DebouncedOnChange
import ServiceManagement

// MARK: - Popover (MenuBarExtra)

struct ContentView: View {
    @State var text = loadInitialText()
    @State private var launchAtLogin = (SMAppService.mainApp.status == .enabled)
    @Environment(\.openWindow) private var openWindow

    var wordCount: Int {
        text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }

    var body: some View {
        VStack {
            ZStack {
                Image(systemName: "square.and.pencil")
                    .imageScale(.large)
                    .foregroundStyle(.primary)
                HStack(spacing: 12) {
                    Spacer()
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(text, forType: .string)
                    } label: {
                        Image(systemName: "doc.on.doc").imageScale(.small)
                    }
                    .buttonStyle(.plain)
                    .help("Copy to clipboard")

                    Button {
                        text = ""
                        saveText(data: "")
                    } label: {
                        Image(systemName: "trash").imageScale(.small)
                    }
                    .buttonStyle(.plain)
                    .help("Clear note")

                    Button {
                        openWindow(id: "jot-pinned")
                    } label: {
                        Image(systemName: "pin").imageScale(.small)
                    }
                    .buttonStyle(.plain)
                    .help("Open as pinned window")

                    Button { NSApp.terminate(nil) } label: {
                        Image(systemName: "power").imageScale(.small)
                    }
                    .buttonStyle(.plain)
                    .help("Quit Jot")
                }
            }
            Spacer().frame(height: 12)
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .frame(width: 275, height: 300)
                    .font(.system(size: 14))
                    .scrollContentBackground(.hidden)
                    .onChange(of: text, debounceTime: .seconds(3)) { newValue in
                        saveText(data: newValue)
                    }
                if text.isEmpty {
                    Text("Start writing...")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                        .padding(.top, 0)
                        .allowsHitTesting(false)
                }
            }
            HStack {
                Toggle(isOn: $launchAtLogin) {}
                    .toggleStyle(.checkbox)
                    .onChange(of: launchAtLogin) { newValue in
                        try? newValue ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister()
                    }
                Text("Launch at login")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(wordCount == 0 ? "" : "\(wordCount) \(wordCount == 1 ? "word" : "words") · \(text.count) chars")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .frame(height: 16)
        }
        .padding()
    }
}

// MARK: - Pinned Window

struct PinnedWindowContent: View {
    @State var text = loadInitialText()

    var wordCount: Int {
        text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(.primary)
                Spacer()
                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                } label: {
                    Image(systemName: "doc.on.doc").imageScale(.small)
                }
                .buttonStyle(.plain)
                .help("Copy to clipboard")

                Button {
                    text = ""
                    saveText(data: "")
                } label: {
                    Image(systemName: "trash").imageScale(.small)
                }
                .buttonStyle(.plain)
                .help("Clear note")

                Button {
                    NSApp.windows.first { $0.identifier?.rawValue == "jot-pinned" }?.close()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .font(.system(size: 14))
                    .frame(minWidth: 280, minHeight: 300)
                    .scrollContentBackground(.hidden)
                    .onChange(of: text, debounceTime: .seconds(3)) { newValue in
                        saveText(data: newValue)
                    }
                if text.isEmpty {
                    Text("Start writing...")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                        .padding(.top, 0)
                        .allowsHitTesting(false)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)

            HStack {
                Spacer()
                Text(wordCount == 0 ? "" : "\(wordCount) \(wordCount == 1 ? "word" : "words") · \(text.count) chars")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .frame(height: 20)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .background(JotWindowConfigurator())
        .onAppear { text = loadInitialText() }
    }
}

private struct JotWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.identifier = NSUserInterfaceItemIdentifier("jot-pinned")
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.isOpaque = false
            window.backgroundColor = .clear
            window.styleMask = [.borderless, .resizable]
            window.hasShadow = true
            window.isMovableByWindowBackground = true
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
