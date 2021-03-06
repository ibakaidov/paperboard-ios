//
//  ViewController.swift
//  Paperboard
//
//  Created by Andrey Tchernov on 16.08.2018.
//  Copyright © 2018 Ice Rock. All rights reserved.
//

import UIKit

class MainInputViewController: MainKeyboardViewController {
    
    @IBOutlet private weak var inputField: UITextView!
    @IBOutlet weak var clearButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsButtonWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        setupStatusBar()
        
        clearButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8)
        clearButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
        
        talkButton?.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8)
        talkButton?.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
        
        inputField.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        inputProcessor = InputFieldProcessor(inputField: inputField)
        
        let isCompact = UIDevice.current.userInterfaceIdiom == .phone
        if let originalFontSize = inputField.font?.pointSize {
            inputField.font = inputField.font?.withSize(isCompact ? originalFontSize/2 : originalFontSize)
        }
        
        inputField.layer.cornerRadius = isCompact ? 5.0 : 8.0
        inputField.layer.borderWidth = 2.0
        
        super.viewDidLoad()
        setColorScheme(.light)
    }
    
    override func setColors(colorScheme: PaperboardColors) {
        super.setColors(colorScheme: colorScheme)
        inputField.layer.borderColor = inputSource.colorScheme.main.backgroundColor.cgColor
    }
    
    func setupStatusBar() {
        if #available(iOS 13.0, *) {
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.statusBarFrame.size.height
            
            let statusbarView = UIView()
            statusbarView.backgroundColor = UIColor.white
            view.addSubview(statusbarView)
            
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor
                .constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor
                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor
                .constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor).isActive = true
            
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = UIColor.white
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        inputSource.reload()
        inputCollectionView.reloadData()
        inputCollectionProcessor.scrollsToMiddleSection(inputCollectionView)
        inputField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adjustSize()
        
        if let visibleIndex = inputCollectionView.indexPathsForVisibleItems.min() {
            inputCollectionView.scrollToItem(at: visibleIndex, at: .left, animated: false)
        }
    }
    
    @IBAction func showSettings(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsSplitViewController
        vc.settings = settings
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func showShare(_ sender: Any) {
        guard let shareText = inputField.text else {
            return
        }
        let textToShare = [ shareText ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop ]
        if let popOver = activityViewController.popoverPresentationController, let shareButton = shareButton {
            popOver.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect = shareButton.frame
        }
        present(activityViewController, animated: false, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        adjustSize()
        
        let visibleIndex = inputCollectionView.indexPathsForVisibleItems.min()
        coordinator.animate(
            alongsideTransition: nil,
            completion: { [weak self] (context) in
                self?.inputLayout.prepare()
                guard let nIndexPath = visibleIndex else {
                    return
                }
                self?.inputCollectionView.reloadData()
                self?.inputCollectionView.scrollToItem(at: nIndexPath, at: .left, animated: false)
            })
    }
    
    func adjustSize() {
        if UIDevice.current.orientation.isLandscape {
            clearButtonWidthConstraint = clearButtonWidthConstraint.changeMultiplier(multiplier: 0.173)
            settingsButtonWidthConstraint = settingsButtonWidthConstraint.changeMultiplier(multiplier: 0.096)
            
            clearButton.setTitle(PaperboardMessages.clear.text, for: .normal)
            talkButton?.setTitle(PaperboardMessages.talk.text, for: .normal)
        } else {
            clearButtonWidthConstraint = clearButtonWidthConstraint.changeMultiplier(multiplier: 0.143)
            settingsButtonWidthConstraint = settingsButtonWidthConstraint.changeMultiplier(multiplier: 0.143)
            
            clearButton.setTitle("", for: .normal)
            talkButton?.setTitle("", for: .normal)
        }
    }
    
    override func configureSpacing(spacing: Int) {
        super.configureSpacing(spacing: spacing)
        inputField.configureSpacing(spacing: spacing)
    }
}
