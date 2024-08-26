//
//  PremiumViewModel.swift
//  Серотоника
//
//  Created by Илья Кузнецов on 24.08.2024.
//

import Foundation
import StoreKit

@MainActor
class PremiumViewModel: ObservableObject {
    
    let productsIDs = ["monthly.subscription.serotonika.com", "yearly.subscription.serotonika.com"]
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductsIDs = Set<String>()
    
    private var productsLoaded = false
    
    var hasUnlockedPremuim: Bool {
        return !purchasedProductsIDs.isEmpty
    }
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
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
            await transaction.finish()
            await updatePurchasedProducts()
        case let .success(.unverified(_, error)):
            print(error)
            break
        case .pending:
            break
        case .userCancelled:
            break
        @unknown default:
            break
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.revocationDate == nil {
                purchasedProductsIDs.insert(transaction.productID)
            } else {
                purchasedProductsIDs.remove(transaction.productID)
            }
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await verificationResult in Transaction.updates {
                await updatePurchasedProducts()
            }
        }
    }
    
}
