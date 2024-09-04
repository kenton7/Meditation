//
//  PremiumViewModel.swift
//  Серотоника
//
//  Created by Илья Кузнецов on 24.08.2024.
//

import Foundation
import StoreKit
import FirebaseDatabase
import FirebaseAuth

@MainActor
class PremiumViewModel: ObservableObject {
    
    let productsIDs = ["monthly.subscription.serotonika.com", "yearly.subscription.serotonika.com"]
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductsIDs = Set<String>()
    private let yandexViewModel = YandexAuthorization.shared
    
    private var productsLoaded = false
    static let shared = PremiumViewModel()
    
    var hasUnlockedPremuim: Bool {
        return !purchasedProductsIDs.isEmpty
    }
    
    private var updates: Task<Void, Never>? = nil
    
    private init() {
        updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
    
    func checkPremium() -> Bool {
        return hasUnlockedPremuim
    }

    func loadProducts() async throws {
        guard !productsLoaded else { return }
        products = try await Product.products(for: productsIDs)
        productsLoaded = true
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case let .success(.verified(transaction)):
            print("Purchase successful for productID: \(transaction.productID), finishing transaction...")
            await transaction.finish()
            await updatePurchasedProducts()
            //try await Database.database(url: .databaseURL).reference().child("users").child(Auth.auth().currentUser?.uid ?? yandexViewModel.yandexUserID).child("isPremium").setValue(hasUnlockedPremuim)
            if Auth.auth().currentUser?.uid != nil || !yandexViewModel.yandexUserID.isEmpty {
                try await Database.database(url: .databaseURL).reference().child("users").child(Auth.auth().currentUser?.uid ?? yandexViewModel.yandexUserID).child("isPremium").setValue(hasUnlockedPremuim)
            }
        case let .success(.unverified(_, error)):
            print("Purchase unverified for productID: \(product.id), error: \(error.localizedDescription)")
        case .pending:
            print("Pending transaction for productID: \(product.id)...")
        case .userCancelled:
            print("User cancelled purchase for productID: \(product.id).")
        @unknown default:
            print("Unknown purchase state for productID: \(product.id).")
        }
    }
    
//    func updatePurchasedProducts() async {
//        print("Updating purchased products...")
//        purchasedProductsIDs.removeAll()
//        for await result in Transaction.currentEntitlements {
//            guard case .verified(let transaction) = result else { print("Unverified transaction found: \(result)")
//                continue
//            }
//            print("Transaction found for productID: \(transaction.productID)")
//            if transaction.revocationDate == nil {
//                purchasedProductsIDs.insert(transaction.productID)
//                print("ProductID \(transaction.productID) added to purchasedProductsIDs.")
//            } else {
//                purchasedProductsIDs.remove(transaction.productID)
//                print("ProductID \(transaction.productID) removed from purchasedProductsIDs.")
//            }
//        }
//        print("Final purchasedProductsIDs: \(purchasedProductsIDs)")
//        do {
//            try await Database.database(url: .databaseURL).reference().child("users").child(Auth.auth().currentUser?.uid ?? yandexViewModel.yandexUserID).child("isPremium").setValue(hasUnlockedPremuim)
//        } catch {
//            print("error when updating isPremuim value in Database: \(error)")
//        }
//    }
    
    func updatePurchasedProducts() async {
        print("Updating purchased products...")

        purchasedProductsIDs.removeAll() // Сбрасываем перед обновлением

        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                print("Verified transaction found for productID: \(transaction.productID), revocationDate: \(String(describing: transaction.revocationDate))")
                
                // Проверяем, что транзакция активна и не была отозвана
                if transaction.revocationDate == nil {
                    purchasedProductsIDs.insert(transaction.productID)
                    print("ProductID \(transaction.productID) added to purchasedProductsIDs.")
                } else {
                    print("Transaction for productID \(transaction.productID) has been revoked or expired.")
                    purchasedProductsIDs.remove(transaction.productID)
                }
            case .unverified(_, let error):
                print("Unverified transaction found with error: \(error.localizedDescription)")
            }
        }
        
        print("Final purchasedProductsIDs: \(purchasedProductsIDs)")

        do {
            if Auth.auth().currentUser?.uid != nil || !yandexViewModel.yandexUserID.isEmpty {
                try await Database.database(url: .databaseURL).reference().child("users").child(Auth.auth().currentUser?.uid ?? yandexViewModel.yandexUserID).child("isPremium").setValue(hasUnlockedPremuim)
            }
        } catch {
            print("Error when updating isPremium value in Database: \(error)")
        }
    }




    
//    func updatePurchasedProducts() async {
//        print("Updating purchased products...")
//        purchasedProductsIDs.removeAll()
//        
//        for await result in Transaction.currentEntitlements {
//            guard case .verified(let transaction) = result else {
//                print("Unverified transaction found: \(result)")
//                continue
//            }
//            
//            print("Transaction found for productID: \(transaction.productID)")
//            
//            if transaction.revocationDate == nil {
//                purchasedProductsIDs.insert(transaction.productID)
//                print("ProductID \(transaction.productID) added to purchasedProductsIDs.")
//            } else {
//                purchasedProductsIDs.remove(transaction.productID)
//                print("ProductID \(transaction.productID) removed from purchasedProductsIDs.")
//            }
//        } 
//        print("Final purchasedProductsIDs: \(purchasedProductsIDs)")
//    }

//    @MainActor
//    func refreshProducts() async {
//        do {
//            // Перезагружаем продукты, чтобы обновить состояние
//            productsLoaded = false
//            try await loadProducts()
//            
//            // Обновляем статус приобретённых продуктов
//            await updatePurchasedProducts()
//            
//        } catch {
//            print("Failed to refresh products: \(error)")
//        }
//    }
    
    @MainActor
    func refreshProducts() async {
        do {
            productsLoaded = false // Сброс кеша загруженных продуктов
            try await loadProducts() // Перезагрузка списка продуктов
            
            // Не вызываем updatePurchasedProducts() здесь!
            // Обновление транзакций должно быть вызвано отдельно, например, при изменении транзакций
        } catch {
            print("Failed to refresh products: \(error)")
        }
    }


    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await result in Transaction.updates {
                print("Transaction update detected: \(result)")
                await updatePurchasedProducts() // Обновляем транзакции
                await refreshProducts() // Обновляем продукты только при изменении транзакций
            }
        }
    }


    
//    private func observeTransactionUpdates() -> Task<Void, Never> {
//        Task(priority: .background) { [unowned self] in
//            for await _ in Transaction.updates {
//                await updatePurchasedProducts()
//            }
//        }
//    }
}
