//
//  ModalConnectionInfo.swift
//  sshApp
//
//  Created by Carlos Escobar on 9/05/21.
//

import SwiftUI
import NMSSH
import Firebase

struct ModalConnectionInfo: View {
    @State var connectionAttr: connection
    @EnvironmentObject var connections: ConnectionsObject
    @State var alertShow : alertText?
    var body: some View {
        let db = Firestore.firestore()
        let uid = UIDevice.current.identifierForVendor?.uuidString
        VStack{
            Text("\(self.connectionAttr.host)")
                .font(.largeTitle)
                .bold()
                .padding(.top, 10)
            Form{
                Section(header: Text("Conexion"), content: {
                    HStack(){
                        Text("Host")
                        Spacer()
                        TextField("Host", text: self.$connectionAttr.host)
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                            .disableAutocorrection(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            
                    }
                        
                    HStack{
                        Text("Puerto")
                        Spacer()
                        TextField("Port", value: self.$connectionAttr.port, formatter: NumberFormatter())
                            .disableAutocorrection(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            .keyboardType(/*@START_MENU_TOKEN@*/.decimalPad/*@END_MENU_TOKEN@*/)
                    }
                })
                
                
                Section(header: Text("Login Info"), content: {
                    HStack{
                        Text("Usuario")
                        Spacer()
                        TextField("User", text: self.$connectionAttr.user)
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                            .disableAutocorrection(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    }
                    HStack{
                        Text("Contraseña")
                        Spacer()
                        SecureField("Password", text: self.$connectionAttr.password)
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                            .disableAutocorrection(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    }
                })
                
                Section(content: {
                    VStack(){
                        Button(action: {
                            let data = [
                                "host": self.connectionAttr.host,
                                "port": Int(self.connectionAttr.port) ?? 22,
                                "user": self.connectionAttr.user,
                                "password": self.connectionAttr.password,
                                "id": "\(connectionAttr.id)",
                                "status": 1
                            ] as [String : Any]
                            db.collection(uid! as String).document("\(self.connectionAttr.id)").updateData(data) { err in
                                if let err = err {
                                    print("Error updating document: \(err)")
                                } else {
                                    self.alertShow = alertText(title: "Exito", text: "Conexion actualizada con exito")
                                    print("Document successfully updated")
                                }
                            }
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
                        }, label: {
                            HStack{
                                Image(systemName: "square.and.pencil")
                                Text("Editar conexion")
                            }
                        })
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color(red: 0, green: 0, blue: 255))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .cornerRadius(10.0)
                    }
                    Section(content: {
                        Button(action: {
                            let data = [
                                "status": 0
                            ]
                            print("------ \(uid! as String) -------- \(self.connectionAttr.id)")
                            db.collection(uid! as String).document("\(self.connectionAttr.id)").updateData(data) { err in
                                if let err = err {
                                    print("Error updating document: \(err)")
                                } else {
                                    print("Document successfully updated")
                                }
                            }
                            print("+++++++++++++++++++++++++++++++")
                            connections.connectionsArray = []
                            db.collection(uid! as String).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                    self.alertShow = alertText(title: "Error", text: "\(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        if(document.data()["status"] as! Int != 0){
                                            print("\(document.documentID) => \(document.data())")
                                            connections.connectionsArray.append(connection(id: UUID(uuidString: document.data()["id"] as! String)!, host: (document.data()["host"]) as! String, port: (document.data()["port"]) as! Int, user: (document.data()["user"]) as! String, password: (document.data()["password"]) as! String))
                                        }
                                    }
                                    self.alertShow = alertText(title: "Exito", text: "Conexion eliminada con exito")
                                }
                            }
                        }, label: {
                            HStack{
                                Image(systemName: "trash")
                                Text("Eliminar conexion")
                            }
                        })
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color(red: 255, green: 0, blue: 0))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .cornerRadius(10.0)
                    })
                    .alert(item: $alertShow) { show in
                        Alert(title: Text(show.title), message: Text(show.text), dismissButton: .cancel())
                    }
                })
            }
            .padding(.top, 20.0)
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Text("Conectar")
            })
            .font(.largeTitle)
        }
    }
}

struct ModalConnectionInfo_Previews: PreviewProvider {
    static var previews: some View {
        ModalConnectionInfo(connectionAttr: connection(host: "ipsum", user: "ipsum", password: "ipsum"))
    }
}

func connect(host: String, port: Int, user: String, password: String)-> String{
    print("Button")
    if(host != "" && user != "" && password != ""){
        let session = NMSSHSession(host: host, port: Int(port) ?? 22, andUsername: user)
        session.connect()
        if(session.isConnected){
            session.authenticate(byPassword: password)
        }else{
            print("No se pudo conectar al host revise")
        }
        
        if(session.isAuthorized){
            var response = session.channel.execute("ls -a", error: nil)
            if(response != nil){
                print("\(response)")
                return response;
            }
            session.disconnect()
        }else{
            print("Error De autenticacion")
        }
    }
    return ""
}
