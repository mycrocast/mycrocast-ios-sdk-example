import Foundation
import UIKit
import MycrocastSDK

/**
 An example view where a user can report a chat message and therefore the specific user

 To open this view, the user needs to select a chat cell and hit the report entry
 */
class ChatReport: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    private let reasonTitle: UILabel = UILabel(frame: .zero)
    private let reasonPicker: UIPickerView = UIPickerView(frame: .zero)
    private let reportTitle: UILabel = UILabel(frame: .zero)
    private let reportDescriptionTitle: UILabel = UILabel(frame: .zero)
    private let reportDescription: UITextView = UITextView(frame: .zero)
    private let cancelButton: UIButton = UIButton(frame: .zero)
    private let sendReport: UIButton = UIButton(frame: .zero)

    private let chatMessage: Message

    init(_ chatMessage: Message) {
        self.chatMessage = chatMessage
        super.init(frame: .zero)

        self.backgroundColor = Colors.darkBackground
        self.createViews()
    }

    private func createViews() {

        self.cancelButton.setTitle("X", for: .normal)
        self.cancelButton.setTitleColor(.white, for: .normal)
        self.cancelButton.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.cancelButton.setContentHuggingPriority(.required, for: .horizontal)
        self.cancelButton.setContentHuggingPriority(.required, for: .vertical)
        self.addSubview(self.cancelButton)

        self.cancelButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        self.cancelButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true

        self.reportTitle.text = "Report chat user"
        self.reportTitle.textColor = .white
        self.reportTitle.font = .systemFont(ofSize: 18)
        self.reportTitle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.reportTitle)

        self.reportTitle.topAnchor.constraint(equalTo: self.cancelButton.bottomAnchor).isActive = true
        self.reportTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        self.reportTitle.trailingAnchor.constraint(equalTo: self.cancelButton.leadingAnchor).isActive = true

        self.reasonTitle.text = "Please select a reason for this report"
        self.reasonTitle.textColor = .white
        self.reasonTitle.font = .systemFont(ofSize: 12)
        self.reasonTitle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.reasonTitle)

        self.reasonTitle.topAnchor.constraint(equalTo: self.reportTitle.bottomAnchor, constant: 5).isActive = true
        self.reasonTitle.leadingAnchor.constraint(equalTo: self.reportTitle.leadingAnchor).isActive = true
        self.reasonTitle.trailingAnchor.constraint(equalTo: self.reportTitle.trailingAnchor).isActive = true

        self.reasonPicker.delegate = self
        self.reasonPicker.dataSource = self
        self.reasonPicker.selectRow(0, inComponent: 0, animated: false)
        self.reasonPicker.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.reasonPicker)

        self.reasonPicker.topAnchor.constraint(equalTo: self.reportTitle.bottomAnchor, constant: -5).isActive = true
        self.reasonPicker.leadingAnchor.constraint(equalTo: self.reasonTitle.leadingAnchor).isActive = true
        self.reasonPicker.trailingAnchor.constraint(equalTo: self.reasonTitle.trailingAnchor).isActive = true

        self.reportDescriptionTitle.font = .systemFont(ofSize: 12)
        self.reportDescriptionTitle.text = "Provide further information (optional)"
        self.reportDescriptionTitle.textColor = .white
        self.reportDescriptionTitle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.reportDescriptionTitle)

        self.reportDescriptionTitle.topAnchor.constraint(equalTo: self.reasonPicker.bottomAnchor, constant: -10).isActive = true
        self.reportDescriptionTitle.leadingAnchor.constraint(equalTo: self.reasonPicker.leadingAnchor).isActive = true
        self.reportDescriptionTitle.trailingAnchor.constraint(equalTo: self.reasonPicker.trailingAnchor).isActive = true

        self.reportDescription.layer.cornerRadius = 5
        self.reportDescription.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.reportDescription)

        self.reportDescription.topAnchor.constraint(equalTo: self.reportDescriptionTitle.bottomAnchor, constant: 0).isActive = true
        self.reportDescription.leadingAnchor.constraint(equalTo: self.reasonPicker.leadingAnchor).isActive = true
        self.reportDescription.trailingAnchor.constraint(equalTo: self.reasonPicker.trailingAnchor).isActive = true
        self.reportDescription.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.reportDescription.textColor = .white
        self.reportDescription.backgroundColor = Colors.lightBackground

        self.sendReport.translatesAutoresizingMaskIntoConstraints = false
        self.sendReport.addTarget(self, action: #selector(self.onSendReport), for: .touchUpInside)
        self.sendReport.setTitle("Send report", for: .normal)
        self.sendReport.setTitleColor(.white, for: .normal)
        self.sendReport.backgroundColor = Colors.lightBackground
        self.addSubview(self.sendReport)
        self.sendReport.layer.cornerRadius = 5

        self.sendReport.topAnchor.constraint(equalTo: self.reportDescription.bottomAnchor, constant: 10).isActive = true
        self.sendReport.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.onViewClicked(_:)))
        self.addGestureRecognizer(gesture)
    }

    @objc private func onCancel() {
        self.removeFromSuperview()
    }

    @objc private func onViewClicked(_ gestureRecognizer: UITapGestureRecognizer) {
        self.reportDescription.resignFirstResponder()
    }

    /**
     We send the report with the selected reason and the optional provided additional information
     */
    @objc private func onSendReport() {
        let reportReason = ReportReason.allCases[self.reasonPicker.selectedRow(inComponent: 0)]
        var info = ""
        if let additional = self.reportDescription.text {
           info = additional
        }
        Mycrocast.shared.chat.reportChatMessage(message: self.chatMessage, reason: reportReason, additionalInformation: info) { success, error in
            // we could show some kind of message here
        }
        self.removeFromSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ReportReason.allCases.count
    }

    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let reportReason = ReportReason.allCases[row].rawValue

        let reportReasonTitle = NSAttributedString(string: reportReason, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        return reportReasonTitle
    }
}
