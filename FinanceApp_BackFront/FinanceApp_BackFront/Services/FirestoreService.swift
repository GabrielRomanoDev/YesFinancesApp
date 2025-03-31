//
//  Firestore.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 29/06/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol FirestoreObject: Codable {
    var id: String { get }
}

class FirestoreService {
    private let db = Firestore.firestore()
    public var user: String
    private var subCollectionName: String
    
    private var collectionRef: CollectionReference {
        return db.collection("users").document(user).collection(subCollectionName)
    }
    
    init(subCollectionName: String = "default") {
        self.user = "user_" + userLogged
        self.subCollectionName = subCollectionName
    }
    
    func setUser(_ userUid: String) {
        user = "user_" + userLogged
    }
    
    func setSubCollectionName(_ name: String) {
        self.subCollectionName = name
    }
    
    func setObject <T: FirestoreObject> (_ object: T, subCollectionName: String? = nil, completion: @escaping (String) -> Void) {
        
        var collection: CollectionReference
        
        if let subCollection = subCollectionName {
            collection = db.collection("users").document(self.user).collection(subCollection)
        } else {
            collection = collectionRef
        }
        
        Task {
            do {
                
                let objectData = try Firestore.Encoder().encode(object)
                try await collection.document(object.id).setData(objectData)
                completion("Success")
                
            } catch {
                completion(error.localizedDescription)
            }
        }
    
    }
    
    func deleteObject(id: String, completion: @escaping (String) -> Void) {
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
    
    func getObjectsList<T: FirestoreObject>(forObjectType objectType: T.Type, documentReadName: String, completion: @escaping (Result<[T], Error>) -> Void) {
        
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
    
    func getLastObjectsList<T: FirestoreObject>(forObjectType objectType: T.Type, documentReadName: String, limit: Int, completion: @escaping (Result<[T], Error>) -> Void) {
        
        self.setSubCollectionName(documentReadName)
        let colRef = collectionRef.order(by: "date", descending: true).limit(to: 4)
        
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
    
    func getObject<T: FirestoreObject>(subCollectionName: String, objectType: T.Type, completion: @escaping (T) -> Void) {
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
                completion(Profile(id: "", name: "Erro", email: "erro") as! T)
            }
        }
        
    }
    
    func updateObjectField(change: [AnyHashable : Any], objectID: String) {
        collectionRef.document(objectID).updateData(change) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func setObjectsList<T: FirestoreObject>(objects: [T], completion: @escaping (String) -> Void) {
        
        let batch = db.batch()
        
        for object in objects {
            do {
                let documentRef = collectionRef.document(object.id)
                try batch.setData(from: object, forDocument: documentRef)
            } catch let error {
                print("Error writing document: \(error.localizedDescription)!")
            }
            
        }
        
        batch.commit { error in
            if let error = error {
                completion("Error setting documents: \(error)")
            } else {
                completion("Success")
            }
        }
        
    }
    
}
