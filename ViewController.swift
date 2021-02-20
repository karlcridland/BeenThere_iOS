//
//  ViewController.swift
//  Been There
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var container: Container?
    let pickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        
        Settings.shared.home = self
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            Location.shared.locationManager?.requestWhenInUseAuthorization()
            if let layout = self.view.superview?.layoutMargins{
                Settings.shared.upper_bound = layout.top
                Settings.shared.lower_bound = layout.bottom
            }
            self.startUp()
        })
    }
    
    func startUp(){
        if Settings.shared.isSignedIn(){
            view.removeAll()
            Firebase.shared.getFollowing()
            Firebase.shared.countNotifications()
            container = Container()
            view.addSubview(container!)

            pickerController.allowsEditing = false
            pickerController.sourceType = .photoLibrary
            pickerController.delegate = self
            
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
        }
        else{
            let form = Register()
            Settings.shared.regForm = form
            view.addSubview(form)
            
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let page = container?.pages.last as? PageUpload{
                page.button.setImage(pickedImage, for: .normal)
                page.tagButton.resetTags()
                page.tagButton.isHidden = false
                page.caption.isHidden = false
                page.caption.input.becomeFirstResponder()
                page.tagButton.check()
                
                if let page = container?.banner?.penultimate() as? PageProfile{
                    if page.isEditing || page.target != nil{
                        container?.banner?.rightClicked()
                        container?.banner?.update()
                    }
                    if let target = page.target{
                        page.target = nil
                        Firebase.shared.uploadTAL(pickedImage, target.scroll as? TALScrollView)
                    }
                }
                if let page = container?.banner?.penultimate() as? PageCreatePost{
                    page.poster.setImage(pickedImage, for: .normal)
                    container?.remove()
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        if let _ = container?.banner?.penultimate() as? PageProfile{
            container?.remove()
        }
    }
    
    func gestureRecognizer(
      _ gestureRecognizer: UIGestureRecognizer,
      shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
      return true
    }
}
