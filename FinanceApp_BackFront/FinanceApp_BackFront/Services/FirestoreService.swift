//
//  Firestore.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 29/06/23.
//

import Foundation
import FirebaseFirestore

protocol FirestoreObject: Codable {
    var id: String { get }
}

class FirestoreService {
    
    static let shared = FirestoreService()
    
    private init(){}
    

//  self.user = "user_" + userLogged


    
    private let db = Firestore.firestore()
    public var user: String = "user_" + userLogged

    private var userDocumentRef: DocumentReference {
        return db.collection("users").document(user)
    }
    
    func setUser(_ userUid: String) {
        user = "user_" + userLogged
    }
    
    func setObject <T: FirestoreObject> (_ object: T, subCollection: String, completion: @escaping (String) -> Void) {
       
        var collection = userDocumentRef.collection(subCollection)
        
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
    
    func deleteObject(id: String, subCollection: String, completion: @escaping (String) -> Void) {
        Task {
            do {
                
                try await userDocumentRef.collection(subCollection).document(id).delete()
                
                completion("Success")
                
            } catch {
                print("Error adding documents: \(error)")
                completion(error.localizedDescription)
            }
        }
    }
    
    func getObjectsList<T: FirestoreObject>(forObjectType objectType: T.Type, subCollection: String, completion: @escaping (Result<[T], Error>) -> Void) {
        
        var collection = userDocumentRef.collection(subCollection)
        
        Task {
            var objectList: [T] = []
            
            do {
                let querySnapshot = try await collection.getDocuments()
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
    
    func getLastObjectsList<T: FirestoreObject>(forObjectType objectType: T.Type, subCollection: String, limit: Int, completion: @escaping (Result<[T], Error>) -> Void) {
        
        var collection = userDocumentRef.collection(subCollection)
        collection.order(by: "date", descending: true).limit(to: 4)
        
        Task {
            var objectList: [T] = []
            
            do {
                let querySnapshot = try await collection.getDocuments()
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
    
    func getObject<T: FirestoreObject>(subCollection: String, objectType: T.Type, completion: @escaping (T) -> Void) {
        
        var collection = userDocumentRef.collection(subCollection)
        
        Task {
            
            do {
                let querySnapshot = try await collection.getDocuments()
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
    
    func updateObjectField(change: [AnyHashable : Any], objectID: String, subCollection: String) {
        
        var collection = userDocumentRef.collection(subCollection)
        
        collection.document(objectID).updateData(change) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func setObjectsList<T: FirestoreObject>(objects: [T], subCollection: String, completion: @escaping (String) -> Void) {
        
        var collection = userDocumentRef.collection(subCollection)
        
        let batch = db.batch()
        var encodingError: Error?
        
        for object in objects {
            do {
                let documentRef = collection.document(object.id)
                let objectData = try Firestore.Encoder().encode(object)
                batch.setData(objectData, forDocument: documentRef)
            } catch {
                encodingError = error
                break
            }
        }
        
        if let error = encodingError {
            completion("Encoding error: \(error.localizedDescription)")
            return
        }
        
        batch.commit { error in
            if let error = error {
                completion("Error setting documents: \(error.localizedDescription)")
            } else {
                completion("Success")
            }
        }
    }
    
}
