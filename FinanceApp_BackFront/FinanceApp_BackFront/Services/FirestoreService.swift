//
//  Firestore.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 29/06/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreService {
    private let db = Firestore.firestore()
    public var user: String
    private var subCollectionName: String
    
    private var collectionRef: CollectionReference {
        return db.collection("users").document(user).collection(subCollectionName)
    }
    
    init(subCollectionName: String = "default") {
        self.user = "user_" + (userLogged ?? "default")
        self.subCollectionName = subCollectionName
    }
    
    public func setUser(_ userUid: String) {
        user = "user_" + (userLogged ?? "default")
    }
    
    public func setSubCollectionName(_ name: String) {
        self.subCollectionName = name
    }
    
    public func addObject <T: Encodable> (_ object: T, id: String, completion: @escaping (String) -> Void) {
        
        Task {
            do {
                
                let objectData = try Firestore.Encoder().encode(object)
                
                try await collectionRef.document(id).setData(objectData)
                
                completion("Success")
                
            } catch {
                print("Error adding documents: \(error)")
                completion(error.localizedDescription)
            }
        }
    
    }
    
    public func updateObject <T: Encodable & Equatable> (_ updatedObject: T, id: String, completion: @escaping (String) -> Void) {
        
        Task {
            do {
                
                let objectData = try Firestore.Encoder().encode(updatedObject)
                
                try await collectionRef.document(id).setData(objectData)
                
                completion("Success")
                
            } catch {
                print("Error adding documents: \(error)")
                completion(error.localizedDescription)
            }
        }
        
    }
    
    public func deleteObject(id: String, completion: @escaping (String) -> Void) {
        Task {
            do {
                
                try await collectionRef.document(id).delete()
                
                completion("Success")
                
            } catch {
                print("Error adding documents: \(error)")
                completion(error.localizedDescription)
            }
        }
    }
    
    public func getObjectsList<T: Codable>(forObjectType objectType: T.Type, documentReadName: String, completion: @escaping (Result<[T], Error>) -> Void) {
        
        self.setSubCollectionName(documentReadName)
        let colRef = collectionRef
        
        Task {
            var objectList: [T] = []
            
            do {
                let querySnapshot = try await colRef.getDocuments()
                for document in querySnapshot.documents {
                    let object = try document.data(as: objectType.self)
                    objectList.append(object)
                }
                completion(.success(objectList))
            } catch {
                completion(.success([]))
            }
        }
        
    }
    
    public func getLastObjectsList<T: Codable>(forObjectType objectType: T.Type, documentReadName: String, limit: Int, completion: @escaping (Result<[T], Error>) -> Void) {
        
        self.setSubCollectionName(documentReadName)
        let colRef = collectionRef.order(by: "Date", descending: true).limit(to: 10)
        
        Task {
            var objectList: [T] = []
            
            do {
                let querySnapshot = try await colRef.getDocuments()
                for document in querySnapshot.documents {
                    let object = try document.data(as: objectType.self)
                    objectList.append(object)
                }
                completion(.success(objectList))
            } catch {
                completion(.success([]))
            }
        }
        
    }
    
    public func setObject<T: Encodable>(_ object: T, subCollectionName: String, completion: @escaping () -> Void) {
        self.setSubCollectionName(subCollectionName)
        do {
            try collectionRef.document().setData(from: object)
            completion()
        } catch let error {
            print("Error writing document: \(error.localizedDescription)!")
            completion()
        }
    }
    
    public func getObject<T: Decodable>(subCollectionName: String, objectType: T.Type, completion: @escaping (T) -> Void) {
        self.setSubCollectionName(subCollectionName)
        Task {
            
            do {
                let querySnapshot = try await collectionRef.getDocuments()
                for document in querySnapshot.documents {
                    let object = try document.data(as: objectType.self)
                    completion(object)
                }
                
            } catch {
                print(error)
                completion(Profile(name: "Erro", email: "erro") as! T)
            }
        }
        
    }
}
