//
//  CreditCardModalScreen.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 25/04/23.
//

import UIKit

protocol CardModalDelegate: AnyObject {
    func didSelectCard(_ indexCategory: Int)
}

class CreditCardModalViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: CardModalDelegate?
    static let identifier:String = String(describing: CreditCardModalViewController.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
    }
    
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CreditCardModalCell.nib(), forCellReuseIdentifier: CreditCardModalCell.identifier)
    }
    
}

extension CreditCardModalViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditCardsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreditCardModalCell.identifier, for: indexPath) as? CreditCardModalCell
        cell?.setupCell(creditCard: creditCardsList[indexPath.row])
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectCard(indexPath.row)
        dismiss(animated: true, completion:  nil)
    }
    
    
}