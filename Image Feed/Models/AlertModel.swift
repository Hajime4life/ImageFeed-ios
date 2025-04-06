import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)
    let secondaryButtonText: String?
    let secondaryButtonCompletion: (() -> Void)?

    init(
        title: String,
        message: String,
        buttonText: String,
        completion: @escaping () -> Void,
        secondaryButtonText: String? = nil,
        secondaryButtonCompletion: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.completion = completion
        self.secondaryButtonText = secondaryButtonText
        self.secondaryButtonCompletion = secondaryButtonCompletion
    }
}
