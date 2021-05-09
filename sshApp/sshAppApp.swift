//
//  sshAppApp.swift
//  sshApp
//
//  Created by Carlos Escobar on 7/05/21.
//

import SwiftUI
import Firebase

struct connection: Identifiable, Hashable{
    var id = UUID()
    var host: String
    var port = 22
    var user: String
    var password: String
}

class ConnectionsObject: ObservableObject {
    @Published var connectionsArray: [connection] = []
}


@main
struct sshAppApp: App {
    init(){
        FirebaseApp.configure()
        
    }
    @StateObject var connections = ConnectionsObject()
    var body: some Scene {
        WindowGroup {
            ContentView(info: "").environmentObject(connections).onAppear(perform: {
                print("UIDevice.current.identifierForVendor?.uuidString \(UIDevice.current.identifierForVendor?.uuidString ?? "simulator")")
            })
        }
    }
}
