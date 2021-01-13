import UIKit
import Vision

class RecognitionViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    
    var request = VNRecognizeTextRequest(completionHandler: nil)
    private let nameController = "Recognition text"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopAnimating()
        self.title = nameController
    }
    
    @IBAction func tappedCameraButton(_ sender: Any) {
        setupPhotoLibrary()
    }
    
    // MARK: - Private
    
    private func setupPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePhotoLibraryPicker = UIImagePickerController()
            imagePhotoLibraryPicker.delegate = self
            imagePhotoLibraryPicker.allowsEditing = true
            imagePhotoLibraryPicker.sourceType = .photoLibrary
            self.present(imagePhotoLibraryPicker, animated: true, completion: nil)
        }
    }
    
    private func setupVisionTextRecognizeImage(image: UIImage?) {
        var textString = ""
        request = VNRecognizeTextRequest(completionHandler: { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                error?.localizedDescription
                return
            }
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else {
                    continue
                }
                textString += "\n\(topCandidate.string)"
                
                DispatchQueue.main.async {
                    self.stopAnimating()
                    self.textView.text = textString
                }
                
            }
        })
        
        request.customWords = ["custOm"]
        request.minimumTextHeight = 0.032
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en_US"]
        request.usesLanguageCorrection = true
        
        let requests = [request]
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let image = image?.cgImage else { fatalError("Missing image to scan")}
            let handle = VNImageRequestHandler(cgImage: image, options: [:])
            try? handle.perform(requests)
        }
    }
    
    private func startAnimating() {
        self.activityIndicator.startAnimating()
    }
    
    private func stopAnimating() {
        self.activityIndicator.stopAnimating()
    }
}

extension RecognitionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        startAnimating()
        self.textView.text = ""
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.imageView.image = image
        setupVisionTextRecognizeImage(image: image)
    }
}

