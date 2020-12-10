//
//  AlertManager.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/09.
//

import UIKit

class AlertManager {
    
    static let shared = AlertManager()
    
    private init() {
        
    }
    
    func okCancel(controller: UIViewController,
                  title: String,
                  message: String,
                  okHandler: ((UIAlertAction) -> Void)?,
                  cancelHandler: ((UIAlertAction) -> Void)?) {
        let okAction = UIAlertAction(title: "확인", style: .default, handler: okHandler)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: cancelHandler)
        showAlert(controller: controller, title: title, message: message, preferredStyle: .alert, actions: [okAction, cancelAction])
    }
    
    func clientIdIsNil(controller: UIViewController) {
        let okAction = UIAlertAction(title: "OK", style: .destructive) { _ in
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        }
        showAlert(controller: controller, title: "에러", message: "ClientID가 없습니다.", preferredStyle: UIAlertController.Style.alert, actions: [okAction])
    }
    
    func coreDataBatchError(controller: UIViewController, message: String) {
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        showAlert(controller: controller, title: "Executing batch operation error!", message: message, preferredStyle: .alert, actions: [okAction])
    }

    func showAlert(controller: UIViewController, title: String?, message: String?, preferredStyle: UIAlertController.Style, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        actions.forEach {
            alert.addAction($0)
        }
        controller.present(alert, animated: false, completion: nil)
    }
}
