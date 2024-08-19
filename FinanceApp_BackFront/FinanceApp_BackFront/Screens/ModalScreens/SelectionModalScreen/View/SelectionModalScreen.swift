//
//  SelectionModalScreen.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 18/08/24.
//

import UIKit

protocol SelectionModalDelegate: AnyObject {
    func didSelectItem(_ index: Int)
}


class SelectionModalScreen: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var titleName: String = ""
    private var list: [String] = []
    private var selectionType: SelectionType
    private var selectionResults: [Bool] = []
    
    static let identifier: String = String(describing: SelectionModalScreen.self)
    weak var delegate: SelectionModalDelegate?
    let viewModel: SelectionModalScreenViewModel?
    
    init?(coder: NSCoder, titleName: String, list: [String], selectionType: SelectionType) {
        self.titleName = titleName
        self.list = list
        self.selectionType = selectionType
        
        
        for _ in list {
            selectionResults.append(false)
        }
        
        self.viewModel = SelectionModalScreenViewModel(selectionType: selectionType, listSelections: self.selectionResults)
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError(globalStrings.initError)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle(text: self.titleName)
        setupTableView()
        
    }
    
    
//    delegate?.didSelectItem(indexPath.row)
    
    private func setupTitle(text: String) {
        titleLabel.text = text
    }
    
    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SelectionTableViewCell.nib(), forCellReuseIdentifier: SelectionTableViewCell.identifier)
    }
    
    private func updateTableView() {
        tableView.reloadData()
    }
}

extension SelectionModalScreen : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectionTableViewCell.identifier, for: indexPath) as? SelectionTableViewCell
        cell?.setupCell(title: list[indexPath.row], itemSelected: self.viewModel?.listSelections[indexPath.row])
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60//viewModel.getHeightSize()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.viewModel?.updateSelections(indexPressed: indexPath.row)
        self.updateTableView()
        
    }
    
}
