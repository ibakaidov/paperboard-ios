//
//  SettingsMasterViewController.swift
//  Paperboard
//
//  Created by Igor Zapletnev on 08.03.2021.
//  Copyright © 2021 Exyte. All rights reserved.
//

import Foundation
import UIKit

enum Setting {
    case columns
    case keyboard
    case symbols
}

class SettingItemCell: UITableViewCell {
    static let id = "SettingItem"
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
}

class SettingsMasterViewController: UITableViewController {
    
    var settings: Settings!
    let items: [Setting] = [Setting.columns, Setting.keyboard, Setting.symbols]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = PaperboardMessages.settingsTitle.text
        
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clear
        
        settings.onColumnAmountChanged.append({ [weak self] newColumns in
            guard let `self` = self else {
                return
            }
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingItemCell {
                cell.valueLabel.text = String(self.settings.currentColumns)
            }
        })
        
        settings.onKeyboardChanged.append({ [weak self] newKeyboard in
            guard let `self` = self else {
                return
            }
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SettingItemCell {
                if let locale = self.settings.currentKeyboard?.locale {
                    cell.valueLabel.text = locale
                } else {
                    cell.valueLabel.text = Locale.current.languageCode
                }
            }
        })
        
        settings.onSymbolsChanged.append({ [weak self] newSymbols in
            guard let `self` = self else {
                return
            }
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SettingItemCell {
                let symbols = self.settings.currentSymbols
                cell.valueLabel.text = symbols.map { self.symbolShortcut(setting: $0) }.joined(separator: " ")
            }
        })
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.middle)
            tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingItemCell.id, for: indexPath) as! SettingItemCell
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(hex: "#F0F0F0")
        cell.selectedBackgroundView = bgColorView
        
        switch items[indexPath.row] {
        case .columns:
            cell.nameLabel.text = PaperboardMessages.settingsColumns.text
            cell.iconView.image = UIImage(named: "columns")
            cell.valueLabel.text = String(settings.currentColumns)
        case .keyboard:
            cell.nameLabel.text = PaperboardMessages.settingsKeyboard.text
            cell.iconView.image = UIImage(named: "globe")
            if let locale = settings.currentKeyboard?.locale {
                cell.valueLabel.text = locale
            } else {
                cell.valueLabel.text = Locale.current.languageCode
            }
        case .symbols:
            cell.nameLabel.text = PaperboardMessages.settingsSymbols.text
            cell.iconView.image = UIImage(named: "symbol")
            let symbols = self.settings.currentSymbols
            cell.valueLabel.text = symbols.map { self.symbolShortcut(setting: $0) }.joined(separator: " ")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        switch items[indexPath.row] {
        case .columns:
            let columnsNavViewController = storyBoard.instantiateViewController(withIdentifier: "ColumnsViewNavController") as! UINavigationController
            let columnsViewController = columnsNavViewController.viewControllers.first as? ColumnsViewController
            columnsViewController?.settings = settings
            splitViewController?.showDetailViewController(columnsNavViewController, sender: nil)
        case .keyboard:
            let keyboardNavViewController = storyBoard.instantiateViewController(withIdentifier: "KeyboardNavViewController") as! UINavigationController
            let keyboardViewController = keyboardNavViewController.viewControllers.first as? KeyboardViewController
            keyboardViewController?.settings = settings
            splitViewController?.showDetailViewController(keyboardNavViewController, sender: nil)
        case .symbols:
            let symbolsNavViewController = storyBoard.instantiateViewController(withIdentifier: "SymbolsNavViewController") as! UINavigationController
            let symbolsViewController = symbolsNavViewController.viewControllers.first as? SymbolsViewController
            symbolsViewController?.settings = settings
            splitViewController?.showDetailViewController(symbolsNavViewController, sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 80
        }
        return 68
    }
    
    func symbolShortcut(setting: Settings.Symbols) -> String {
        switch setting {
        case .currency:
            return "$"
        case .numbers:
            return "1-9"
        case .math:
            return "+-"
        case .punctuation:
            return "!"
        case .extra:
            return "#"
        }
    }
}
