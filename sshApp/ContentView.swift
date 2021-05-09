//
//  ContentView.swift
//  sshApp
//
//  Created by Carlos Escobar on 7/05/21.
//

import SwiftUI
import Firebase


struct ContentView: View {
    @State var info: String
    @State var modalNewConnection = false;
    @State var modalInfoConnection = false;
    @EnvironmentObject var connections: ConnectionsObject
    var body: some View {
        let db = Firestore.firestore()
        let uid = UIDevice.current.identifierForVendor?.uuidString
        var currentConnection = connection(host: "ipsum", user: "ipsum", password: "ipsum")
        NavigationView{
            VStack(){
                if(!connections.connectionsArray.isEmpty){
                    ForEach(connections.connectionsArray, id:\.id) { section in
                        Button(action: {
                            currentConnection = section
                            print("--------\(currentConnection)")
                            self.modalInfoConnection.toggle()
                        }, label: {
                            HStack{
                                Image("terminal")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50)
                                VStack(){
                                    Text("Host: \(section.host)")
                                    Text("User: \(section.user)")
                                }
                            }
                        })
                        .padding()
                        .background(Color(red: 0, green: 0, blue: 0.5))
                        .clipShape(Rectangle())
                        .cornerRadius(10.0)
                    }
                }
                
                Text(info)
            }.onAppear(perform: {
                print("+++++++++++++++++++++++++++++++")
                connections.connectionsArray = []
                db.collection(uid! as String).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            if(document.data()["status"] as! Int != 0){
                                print("\(document.documentID) => \(document.data())")
                                connections.connectionsArray.append(connection(id: UUID(uuidString: document.data()["id"] as! String)!, host: (document.data()["host"]) as! String, port: (document.data()["port"]) as! Int, user: (document.data()["user"]) as! String, password: (document.data()["password"]) as! String))
                            }
                        }
                    }
                }
            })
            .sheet(isPresented: self.$modalInfoConnection){
                ModalConnectionInfo(connectionAttr: currentConnection)
            }
            .navigationBarTitle("Conexiones")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        print("\(self.modalNewConnection)")
                    }, label:{
                        Image(systemName: "info.circle")
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.modalNewConnection.toggle()
                        print("\(self.modalNewConnection)")
                    }, label:{
                        Image(systemName: "plus.app.fill")
                    })
                }
            }
            
        }
        .sheet(isPresented: self.$modalNewConnection){
            ModalNewConnection(showModal: self.$modalNewConnection)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(info: "")
                .environmentObject(ConnectionsObject())
        }.onAppear(perform: {
            ConnectionsObject().connectionsArray.append(connection(host: "ipsumtest", user: "ipsum", password: "ipsum"))
        })
    }
}


