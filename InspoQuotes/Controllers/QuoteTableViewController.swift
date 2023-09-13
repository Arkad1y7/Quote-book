//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Аркадий Шахмелян on 03.09.2023.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController, SKPaymentTransactionObserver {

    let productId = "Вводишь свой id"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
        
        if isPurchased(){
            showPremiumQuotes()
        }
    }
    
    var quotesToShow = [
    "Чем умнее человек, тем легче он признает себя дураком. - Альберт Эйнштейн",
    "Никогда не ошибается тот, кто ничего не делает. - Теодор Рузвельт",
    "Менее всего просты люди, желающие казаться простыми. - Лев Николаевич Толстой",
    "Мы находимся здесь, чтобы внести свой вклад в этот мир. Иначе зачем мы здесь? - Стив Джобс"
    ]
    
    let premiumQuotes = [
    "Если человек не нашёл, за что может умереть, он не способен жить. - Мартин Лютер Кинг",
    "Если кто-то причинил тебе зло, не мсти. Сядь на берегу реки, и вскоре ты увидишь, как мимо тебя проплывает труп твоего врага. - Лао-цзы",
    "Если тебе тяжело, значит ты поднимаешься в гору. Если тебе легко, значит ты летишь в пропасть. - Генри Форд",
    "Лучше быть хорошим человеком, 'ругающимся матом', чем тихой, воспитанной тварью. - Фаина Раневская"
    ]

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPurchased(){
            return quotesToShow.count
        }else{
            return quotesToShow.count + 1
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        if indexPath.row < quotesToShow.count {
            cell.textLabel?.text = quotesToShow[indexPath.row]
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.accessoryType = .none
        }else{
            cell.textLabel?.text = "Get More Quotes"
            cell.textLabel?.textColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    //MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count{
            buyPremiumQuotes()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - In-App Purchase Methods
    func buyPremiumQuotes() {
        if SKPaymentQueue.canMakePayments() {
            //can make payments
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productId
            SKPaymentQueue.default().add(paymentRequest)
        }else{
            //can't make payments
            print("User can't make payments")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            if transaction.transactionState == .purchased {
                //User payment successful
                print("success")
                showPremiumQuotes()
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                //User payment failed
                
                if let error = transaction.error{
                    let errorDescription = error.localizedDescription
                    print("Transaction failed due to error: \(errorDescription)")
                }
                //showPremiumQuotes()
                UserDefaults.standard.set(true, forKey: productId) //записываем ключ в plist
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .restored{
                showPremiumQuotes()
                print("Transaction restored")
                navigationItem.setRightBarButton(nil, animated: true)
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    func showPremiumQuotes(){
        quotesToShow.append(contentsOf: premiumQuotes)
        tableView.reloadData()
    }
    
    func isPurchased() -> Bool{
        let purchasedStatus = UserDefaults.standard.bool(forKey: productId) // обращаемся с ключом от контента в plist
        if purchasedStatus{
            print("Previously purchased")
            return true
        }else{
            print("Never purchased")
            return false
        }
    }
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}
