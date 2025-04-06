import UIKit

class AlertPresenter: AlertPresenterProtocol {
    static func showAlert(model: AlertModel, vc: UIViewController) {
        let alertController = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )

        // Основная кнопка
        let primaryAction = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alertController.addAction(primaryAction)

        // Вторая кнопка (опционально)
        if let secondaryButtonText = model.secondaryButtonText,
           let secondaryButtonCompletion = model.secondaryButtonCompletion {
            let secondaryAction = UIAlertAction(title: secondaryButtonText, style: .cancel) { _ in
                secondaryButtonCompletion()
            }
            alertController.addAction(secondaryAction)
        }

        vc.present(alertController, animated: true, completion: nil)
    }
}
