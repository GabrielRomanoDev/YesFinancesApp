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
    
    private let db = Firestore.firestore()
    public var user: String {
        return "user_" + (AuthenticationManager.shared.getCurrentUser()?.id ?? "error")
    }

    private var userDocumentRef: DocumentReference {
        return db.collection("users").document(user)
    }

    private func completeOnMain(_ completion: @escaping (String) -> Void, with result: String) {
        DispatchQueue.main.async {
            completion(result)
        }
    }

    private func completeOnMain<T>(_ completion: @escaping (Result<T, Error>) -> Void, with result: Result<T, Error>) {
        DispatchQueue.main.async {
            completion(result)
        }
    }

    private static let removableUserSubcollections: [String] = [
        firebaseSubCollectionNames.profile,
        firebaseSubCollectionNames.transactions,
        firebaseSubCollectionNames.creditCardExpenses,
        firebaseSubCollectionNames.bankAccounts,
        firebaseSubCollectionNames.creditCards,
        firebaseSubCollectionNames.goals,
    ]
    
    func getProfileInfo(userId: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        
        let collection = db.collection("users").document("user_\(userId)").collection(firebaseSubCollectionNames.profile)
        
        Task {
            
            do {
                let querySnapshot = try await collection.getDocuments()
                for document in querySnapshot.documents {
                    let object = try document.data(as: UserData.self)
                    completeOnMain(completion, with: .success(object))
                    return
                }
                
                completeOnMain(completion, with: .failure(NSError(domain: "", code: 0, userInfo: nil)))
                
            } catch {
                print(error)
                completeOnMain(completion, with: .failure(error))
            }
        }
        
    }
    
    func setObject <T: FirestoreObject> (_ object: T, subCollection: String, completion: @escaping (String) -> Void) {
       
        let collection = userDocumentRef.collection(subCollection)
        
        Task {
            do {
                
                let objectData = try Firestore.Encoder().encode(object)
                try await collection.document(object.id).setData(objectData)
                completeOnMain(completion, with: "Success")
                
            } catch {
                print("Error to set object: \(error)");
                completeOnMain(completion, with: error.localizedDescription)
            }
        }
    
    }
    
    func deleteObject(id: String, subCollection: String, completion: @escaping (String) -> Void) {
        Task {
            do {
                
                try await userDocumentRef.collection(subCollection).document(id).delete()
                
                completeOnMain(completion, with: "Success")
                
            } catch {
                print("Error adding documents: \(error)")
                completeOnMain(completion, with: error.localizedDescription)
            }
        }
    }
    
    func getObjectsList<T: FirestoreObject>(forObjectType objectType: T.Type, subCollection: String, completion: @escaping (Result<[T], Error>) -> Void) {
        
        let collection = userDocumentRef.collection(subCollection)
        
        
        Task {
            var objectList: [T] = []
            
            do {
                let querySnapshot = try await collection.getDocuments()
                for document in querySnapshot.documents {
                    let object = try document.data(as: objectType.self)
                    objectList.append(object)
                }
                completeOnMain(completion, with: .success(objectList))
            } catch {
                completeOnMain(completion, with: .failure(error))
            }
        }
        
    }
    
    func getLastObjectsList<T: FirestoreObject>(forObjectType objectType: T.Type, subCollection: String, limit: Int, completion: @escaping (Result<[T], Error>) -> Void) {
        
        let collection = userDocumentRef.collection(subCollection)
        let query = collection.order(by: "date", descending: true).limit(to: limit)
        
        Task {
            var objectList: [T] = []
            
            do {
                let querySnapshot = try await query.getDocuments()
                for document in querySnapshot.documents {
                    let object = try document.data(as: objectType.self)
                    objectList.append(object)
                }
                completeOnMain(completion, with: .success(objectList))
            } catch {
                completeOnMain(completion, with: .failure(error))
            }
        }
        
    }
    
    func getObject<T: FirestoreObject>(id: String, subCollection: String, objectType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        
        let docRef = userDocumentRef.collection(subCollection).document(id)
        
        Task {
            
            do {
                let document = try await docRef.getDocument()
                
                if document.exists {
                    let object = try document.data(as: objectType.self)
                    completeOnMain(completion, with: .success(object))
                } else {
                    completeOnMain(completion, with: .failure(NSError(domain: "", code: 0, userInfo: nil)))
                }
                
            } catch {
                print(error)
                completeOnMain(completion, with: .failure(error))
            }
        }
        
    }
    
    func updateObjectField(change: [AnyHashable : Any], objectID: String, subCollection: String) {
        
        let collection = userDocumentRef.collection(subCollection)
        
        collection.document(objectID).updateData(change) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func setObjectsList<T: FirestoreObject>(objects: [T], subCollection: String, completion: @escaping (String) -> Void) {
        
        let collection = userDocumentRef.collection(subCollection)
        
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
            completeOnMain(completion, with: "Encoding error: \(error.localizedDescription)")
            return
        }
        
        batch.commit { error in
            if let error = error {
                self.completeOnMain(completion, with: "Error setting documents: \(error.localizedDescription)")
            } else {
                self.completeOnMain(completion, with: "Success")
            }
        }
    }

    func deleteUserData(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userDocumentRef = db.collection("users").document("user_\(userId)")

        Task {
            do {
                for subcollection in Self.removableUserSubcollections {
                    try await deleteAllDocuments(in: userDocumentRef.collection(subcollection))
                }

                try await userDocumentRef.delete()
                completeOnMain(completion, with: .success(()))
            } catch {
                completeOnMain(completion, with: .failure(error))
            }
        }
    }

    private func deleteAllDocuments(in collection: CollectionReference) async throws {
        let querySnapshot = try await collection.getDocuments()

        guard !querySnapshot.documents.isEmpty else { return }

        let batch = db.batch()
        querySnapshot.documents.forEach { document in
            batch.deleteDocument(document.reference)
        }

        try await batch.commit()
    }
    
}
