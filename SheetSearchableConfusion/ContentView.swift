//
//  ContentView.swift
//  SheetSearchableConfusion
//
//  Created by Jason Ji on 5/26/22.
//

import SwiftUI
import Combine

// When starting and canceling a search in SheetView, the SheetView is dismissed.
// This doesn't occur if you just tap the Change Value button that updates the same value in KeyboardMonitor.
// Nor does it occur if you start to enter text in a TextField and then stop entering it.
// There seems likely to be some sort of clash between the underlying UISearchController's dismissal and the SwiftUI sheet logic.

struct ContentView: View {
    @State var sheetShowing = false
    @State var value = 0
    
    @StateObject var monitor = KeyboardMonitor()
    
    var body: some View {
        let _ = Self._printChanges()
        Button("Sheet") {
            sheetShowing.toggle()
        }
        .sheet(isPresented: $sheetShowing) {
            SheetView(value: $value)
        }
    }
}

struct SheetView: View {
    @Binding var value: Int
    
    var body: some View {
        let _ = Self._printChanges()
        NavigationView {
            VStack {
                Button("Change Value") {
                    NotificationCenter.default.post(name: .changeValue, object: nil)
                }
                TextField("My Text Field", text: Binding.constant("")).border(Color.black)
            }
            .searchable(text: Binding.constant(""))
        }
    }
}

class KeyboardMonitor: ObservableObject {
    var cancellables = Set<AnyCancellable>()
    
    @Published var keyboardVisible = false
    
    init() {
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] _ in
                self?.keyboardVisible = true
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.keyboardVisible = false
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: .changeValue)
            .sink { [weak self] _ in
                self?.keyboardVisible.toggle()
            }
            .store(in: &cancellables)
    }
}

extension Notification.Name {
    static let changeValue = Notification.Name(rawValue: "changeValue")
}
