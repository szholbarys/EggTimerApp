import UIKit
import AVFoundation

class EggTimerViewController: UIViewController {
    
    private let eggTimes: [String: TimeInterval] = [
        "soft": 300,
        "medium": 420,
        "hard": 720
    ]
    
    private let buttonSize: CGFloat = 100
    private var timer: Timer?
    private var totalTime: TimeInterval = 0
    private var remainingTime: TimeInterval = 0
    private var audioPlayer: AVAudioPlayer?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "🥚 Egg Timer"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var softEggButton: UIButton = createEggButton(
        title: "Soft\n5:00",
        image: "boiled_egg",
        color: .systemYellow
    )
    
    private lazy var mediumEggButton: UIButton = createEggButton(
        title: "Medium\n7:00",
        image: "medium_boiled_egg",
        color: .systemOrange
    )
    
    private lazy var hardEggButton: UIButton = createEggButton(
        title: "Hard\n12:00",
        image: "hard_boiled_egg",
        color: .systemRed
    )
    
    private lazy var progressBar: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = .systemYellow
        progress.trackTintColor = .systemGray4
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        progress.layer.sublayers?[1].cornerRadius = 4
        progress.subviews[1].clipsToBounds = true
        return progress
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "00:00"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSound()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        view.addSubview(progressBar)
        view.addSubview(timeLabel)
        
        stackView.addArrangedSubview(softEggButton)
        stackView.addArrangedSubview(mediumEggButton)
        stackView.addArrangedSubview(hardEggButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            progressBar.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            progressBar.heightAnchor.constraint(equalToConstant: 8),
            
            timeLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 15),
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func createEggButton(title: String, image: String, color: UIColor) -> UIButton {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = color
        containerView.layer.cornerRadius = buttonSize / 2
        containerView.clipsToBounds = true
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: image)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        
        containerView.addSubview(imageView)
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: buttonSize),
            containerView.heightAnchor.constraint(equalToConstant: buttonSize),
            
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            imageView.widthAnchor.constraint(equalToConstant: buttonSize * 0.5),
            imageView.heightAnchor.constraint(equalToConstant: buttonSize * 0.5),
            
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5)
        ])
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: buttonSize),
            button.heightAnchor.constraint(equalToConstant: buttonSize),
            containerView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        button.addTarget(self, action: #selector(eggButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func eggButtonTapped(_ sender: UIButton) {
        timer?.invalidate()
        
        let eggType: String
        switch sender {
        case softEggButton: eggType = "soft"
        case mediumEggButton: eggType = "medium"
        case hardEggButton: eggType = "hard"
        default: return
        }
        
        guard let duration = eggTimes[eggType] else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
        
        totalTime = duration
        remainingTime = duration
        progressBar.progress = 1.0
        updateTimeLabel()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        remainingTime -= 0.1
        
        if remainingTime <= 0 {
            timer?.invalidate()
            progressBar.progress = 0
            playAlarmSound()
            showCompletionAlert()
            return
        }
        
        progressBar.progress = Float(remainingTime / totalTime)
        updateTimeLabel()
    }
    
    private func updateTimeLabel() {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func setupSound() {
        guard let soundURL = Bundle.main.url(forResource: "alarm_sound", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading sound: \(error.localizedDescription)")
        }
    }
    
    private func playAlarmSound() {
        audioPlayer?.play()
    }
    
    private func showCompletionAlert() {
        let alert = UIAlertController(
            title: "Timer Complete!",
            message: "Your egg is ready!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
