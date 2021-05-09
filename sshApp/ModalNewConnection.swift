//
//  ModalNewConnection.swift
//  sshApp
//
//  Created by Carlos Escobar on 8/05/21.
//

import SwiftUI
import Firebase


struct alertText: Identifiable{
    var id: String { text }
    var title: String
    var text: String
}
struct ModalNewConnection: View {
    @Binding var showModal: Bool

    @State var host = ""
    @State var port = ""
    @State var user = ""
    @State var password = ""
    
    @State var alertShow : alertText?
    
    
    
    @EnvironmentObject var connectionState: ConnectionsObject
    var body: some View {
        let db = Firestore.firestore()
        let uid = UIDevice.current.identifierForVendor?.uuidString
        VStack(){
            Text("Nueva Conexion")
                .font(.largeTitle)
                .bold()
                .padding(.top, 10)
            Form{
                Section(header: Text("Conexion"), content: {
                    HStack(){
                        Text("Host")
                        Spacer()
                        TextField("Host", text: self.$host)
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                            .disableAutocorrection(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            
                    }
                        
                    HStack{
                        Text("Puerto")
                        Spacer()
                        TextField("Port", text: self.$port)
                            .disableAutocorrection(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            .keyboardType(/*@START_MENU_TOKEN@*/.decimalPad/*@END_MENU_TOKEN@*/)
                    }
                })
                
                
                Section(header: Text("Login Info"), content: {
                    HStack{
                        Text("Usuario")
                        Spacer()
                        TextField("User", text: self.$user)
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                            .disableAutocorrection(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    }
                    HStack{
                        Text("Contraseña")
                        Spacer()
                        SecureField("Password", text: self.$password)
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                            .disableAutocorrection(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    }
                })
            }
            .padding(.top, 20.0)
            Button("Añadir") {
                if(host != "" && user != "" && password != ""){
                    connectionState.connectionsArray.append(connection(host: self.host, port: Int(self.port) ?? 22, user: self.user, password: self.password))
                    print("\(connectionState.connectionsArray)")
                    db.collection(uid! as String).document("\(connectionState.connectionsArray.last!.id)").setData([
                        "host": self.host,
                        "port": Int(self.port) ?? 22,
                        "user": self.user,
                        "password": self.password,
                        "id": "\(connectionState.connectionsArray.last!.id)",
                        "status": 1
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                            self.alertShow = alertText(title: "Error", text: "\(err)")
                        } else {
                            print("Document added")
                        }
                    }
                    self.showModal.toggle()
                }else{
                    self.alertShow = alertText(title: "Error", text: "Llene los campos requeridos")
                }
            }
            .font(.largeTitle)
        }
        .alert(item: $alertShow) { show in
            Alert(title: Text(show.title), message: Text(show.text), dismissButton: .cancel())
        }
        
    }
    
    
}

struct ModalNewConnection_Previews: PreviewProvider {
    @State static var value = true
    static var previews: some View {
        
        ModalNewConnection(showModal: $value)
    }
}



