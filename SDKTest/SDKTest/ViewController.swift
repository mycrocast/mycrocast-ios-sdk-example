import UIKit

import MycrocastSDK

/**
 The initial view of the app that starts the sdk,
 loads the currently live streams and displays them in the stackview
 */
class ViewController: UIViewController, StreamsDelegate {

//    private static let YOUR_CUSTOMER_ID = "1625750816621_d338664f-7a2b-48d9-a601-5d4526b84b11" // replace with your customerId as visible in the mycrocast studio
//    private static let YOUR_API_KEY = "8LL6gRQeArhrp0bJ" // replace with your api key as visible in the mycrocast studio

    private static let YOUR_CUSTOMER_ID = "1567504890375_8741a554-c25e-428f-a807-a69bac373315-9999" //"aaaaa" // replace with your customerId as visible in the mycrocast studio
    private static let YOUR_API_KEY = "fHDYOI1SDw8e5P12" // replace with your api key as visible in the mycrocast studio

    private let streamStack: UIStackView = UIStackView()
    private var cells: [Int: LiveStreamCell] = [:]

    private var noStreams: UILabel = UILabel(frame: .zero);

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view.

        // start the sdk with your credentials
        Mycrocast.shared.start(apiKey: ViewController.YOUR_API_KEY, customerToken: ViewController.YOUR_CUSTOMER_ID) { streams, error in
            if let error = error {
                print(error)
                return
            }
            // we received a successful response from the server without any errors
            // we now have all currently streaming streamers of the club in the streams list
            // we can also access this from the sdks streamManager
            for stream in streams {
                self.onStreamAdded(stream: stream)
            }
        }

        self.streamStack.axis = .vertical
        self.streamStack.translatesAutoresizingMaskIntoConstraints = false
        self.streamStack.spacing = 10
        self.view.addSubview(self.streamStack)

        self.streamStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5).isActive = true
        self.streamStack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        self.streamStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5).isActive = true

        self.view.backgroundColor = Colors.darkBackground
        navigationController?.navigationBar.barTintColor = Colors.richBlack

        self.noStreams.translatesAutoresizingMaskIntoConstraints = false
        self.noStreams.font = .systemFont(ofSize: 17)
        self.noStreams.textColor = .white
        self.noStreams.text = "No stream currently online. Start a stream from the mycrocast app as a streamer from you club."
        self.noStreams.lineBreakMode = .byWordWrapping
        self.noStreams.numberOfLines = 0

        self.view.addSubview(self.noStreams)
        self.noStreams.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.noStreams.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.75).isActive = true
        self.noStreams.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AppDelegate.rootViewController = self

        // register to receive updates for streams
        Mycrocast.shared.streams.addObserver(self)

        self.repopulate()
        self.noStreams.isHidden = Mycrocast.shared.streams.getStreams().count != 0
    }

    override func viewDidDisappear(_ animated: Bool) {
        // Unregister to receive updates for streams
        Mycrocast.shared.streams.removeObserver(self)
    }

    /**
     We selected a cell and now move to the details view of that stream
     - Parameter stream: the stream we want to see the details of
     */
    private func onCellSelected(stream: LiveStream) {
        DispatchQueue.main.async {
            let streamerView = StreamerView(liveStream: stream)
            self.navigationController?.pushViewController(streamerView, animated: true)
        }
    }

    // this is redrawing the cells
    // normally you would instead create a diff here for what was added /removed
    // this is needed because we unsubscribe from the delegate in on viewDidDisappear
    private func repopulate() {
        while (true) {
            let first = self.cells.popFirst()
            guard let entry = first else {
                break;
            }
            entry.value.removeFromSuperview()
        }

        for stream in Mycrocast.shared.streams.getStreams() {
            self.onStreamAdded(stream: stream)
        }
    }

    /**
     A new stream was added therefore we add it to the stack view
     To display it
     - Parameter stream: the added stream
     */
    func onStreamAdded(stream: LiveStream) {
        DispatchQueue.main.async {
            let cell = LiveStreamCell();
            cell.cellCallback = self.onCellSelected
            self.cells[stream.id] = cell;
            cell.updateView(stream: stream)
            self.streamStack.addArrangedSubview(cell)

            self.noStreams.isHidden = Mycrocast.shared.streams.getStreams().count != 0
        }
    }

    /**
     A stream was updated so we refresh the specific stream
     This could be due to change of rating, change of listener count etc
     - Parameter stream:
     */
    func onStreamUpdated(stream: LiveStream) {
        let cell = self.cells[stream.id]
        if let cell = cell {
            DispatchQueue.main.async {
                cell.updateView(stream: stream)
            }
        }
    }

    /**
     A stream was removed this is most likely to the streamer just ending the transmission
     - Parameter stream: the stream that ended
     */
    func onStreamRemoved(stream: LiveStream) {
        let cell = self.cells.removeValue(forKey: stream.id)
        if let cell = cell {
            DispatchQueue.main.async {
                cell.removeFromSuperview()
                self.noStreams.isHidden = Mycrocast.shared.streams.getStreams().count != 0
            }
        }
    }
}

