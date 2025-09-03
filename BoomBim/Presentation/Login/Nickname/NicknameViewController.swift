//
//  NicknameViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/18/25.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

final class NicknameViewController: BaseViewController {
    private let viewModel: NicknameViewModel
    private let disposeBag = DisposeBag()
    
    // 이미지 선택 값을 담아 ViewModel로 전달
    private let pickedImageRelay = BehaviorRelay<UIImage?>(value: nil)
    
    // MARK: - UI
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let nicknameTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.grayScale9
        label.font = Typography.Heading01.semiBold.font
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "nickname.label.title.main".localized()
        
        return label
    }()
    
    private let nicknameSubTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.grayScale8
        label.font = Typography.Caption.regular.font
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "nickname.label.title.sub".localized()
        
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.iconEmptyProfile
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage.iconCamera, for: .normal)
        
        return button
    }()
    
    private let textFieldTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.grayScale8
        label.font = Typography.Body03.regular.font
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "nickname.label.nickname".localized()
        
        return label
    }()
    
    private let nicknameTextField: InsetTextField = {
        let textField = InsetTextField()
        textField.borderStyle = .none
        textField.backgroundColor = .grayScale1
        textField.layer.cornerRadius = 6
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.grayScale4.cgColor
        
        textField.textColor = .grayScale8
        textField.font = Typography.Body03.regular.font
        textField.placeholder = "nickname.textfield.placeholder".localized()
        textField.setPlaceholder(color: .grayScale8)
        
        return textField
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.grayScale4
        button.setTitle( "nickname.button.signup".localized(), for: .normal)
        button.setTitleColor(.grayScale7, for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.layer.cornerRadius = 10
        
        return button
    }()

    init(viewModel: NicknameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nicknameTextField.becomeFirstResponder()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        setupNavigationBar()
        
        configureTitle()
        configureImageView()
        configureTextField()
        configureButton()
        
        bind()
    }
    
    private func setupNavigationBar() {
        title = ""
        
        navigationController?.navigationBar.tintColor = .grayScale9
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    private func configureTitle() {
        [nicknameTitleLabel, nicknameSubTitleLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
        }
        
        NSLayoutConstraint.activate([
            nicknameTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            nicknameTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nicknameTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nicknameSubTitleLabel.topAnchor.constraint(equalTo: nicknameTitleLabel.bottomAnchor, constant: 4),
            nicknameSubTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nicknameSubTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func configureImageView() {
        [profileImageView, cameraButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        let profileImageViewDiameter: CGFloat = 118
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: nicknameSubTitleLabel.bottomAnchor, constant: 28),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: profileImageViewDiameter),
            profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewDiameter),
            
            cameraButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -2),
            cameraButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 9),
        ])
        
        profileImageView.layer.cornerRadius = profileImageViewDiameter / 2
        profileImageView.clipsToBounds = true
    }
    
    private func configureTextField() {
        [textFieldTitleLabel, nicknameTextField].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            textFieldTitleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 32),
            textFieldTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nicknameTextField.topAnchor.constraint(equalTo: textFieldTitleLabel.bottomAnchor, constant: 4),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func configureButton() {
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            signUpButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            signUpButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Binding
    private func bind() {
        let input = NicknameViewModel.Input(
            nicknameText: nicknameTextField.rx.text.orEmpty.asDriver(),
            pickedImage: pickedImageRelay.asDriver(), // UIImage? 전달
            signupTap: signUpButton.rx.tap.asSignal()
        )
        
        let output = viewModel.tansform(input: input)
        
        // 로딩 인디케이터
        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // 로딩 동안 전체 입력 비활성화
        output.isLoading
            .map { !$0 }
            .drive(onNext: { [weak self] enabled in
                self?.nicknameTextField.isEnabled = enabled
                self?.cameraButton.isEnabled = enabled
            })
            .disposed(by: disposeBag)
        
        // 버튼 활성 (검증 결과 ∧ 로딩 아님)
        Driver.combineLatest(output.isSignupEnabled, output.isLoading.map { !$0 }) { $0 && $1 }
            .drive(onNext: { [weak self] isEnabled in
                self?.signUpButton.isEnabled = isEnabled
                switch isEnabled {
                case true:
                    self?.signUpButton.backgroundColor = .main
                    self?.signUpButton.setTitleColor(.grayScale1, for: .normal)
                case false:
                    self?.signUpButton.backgroundColor = UIColor.grayScale4
                    self?.signUpButton.setTitleColor(.grayScale7, for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        // 에러 표시
        output.error
            .emit(onNext: { [weak self] msg in
                self?.presentAlert(title: "오류", message: msg)
            })
            .disposed(by: disposeBag)
        
        let placeholder = UIImage.iconEmptyProfile
        
        print("image : \(profileImageView.image)")

        pickedImageRelay
            .asDriver()
            .map { $0 ?? placeholder }     // ← nil일 때 기본 이미지 유지
            .drive(profileImageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Action
    private func setupActions() {
        setupTextFieldActions()
        setupCameraButtonAction()
    }
    
    private func setupTextFieldActions() {
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.grayScale7.cgColor
        } else {
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.grayScale4.cgColor
        }
    }
    
    private func setupCameraButtonAction() {
        cameraButton.addTarget(self, action: #selector(presentPhotoActionSheet), for: .touchUpInside)
    }
    
    @objc private func presentPhotoActionSheet() {
        let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertView.addAction(UIAlertAction(title: "카메라로 촬영", style: .default) { _ in self.showCamera() })
        alertView.addAction(UIAlertAction(title: "앨범에서 선택", style: .default) { _ in self.showPhotoPicker() })
        alertView.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alertView, animated: true)
    }
}

// MARK: - 카메라 사용 및 앨범 접근
extension NicknameViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    // Camera 사용
    func showCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showPhotoPicker()
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            presentCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    granted ? self?.presentCamera() : self?.showPermissionAlert()
                }
            }
        default:
            showPermissionAlert()
        }
    }
    
    private func presentCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "카메라 권한 필요",
            message: "설정 > 개인정보 보호 > 카메라에서 권한을 허용해 주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        picker.dismiss(animated: true) {
            guard let image else { return }
            
            self.profileImageView.image = image
            self.pickedImageRelay.accept(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // 앨범 접근
    func showPhotoPicker(selectionLimit: Int = 1) {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = selectionLimit  // 1 = 단일 선택, 0 = 무제한
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            present(picker, animated: true)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    granted ? self?.presentCamera() : self?.showPhotoLibraryPermissionAlert()
                }
            }
        default:
            showPhotoLibraryPermissionAlert()
        }
    }
    
    private func showPhotoLibraryPermissionAlert() {
        let alert = UIAlertController(
            title: "앨범 접근 권한 필요",
            message: "설정 > 개인정보 보호 > 사진에서 권한을 허용해 주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] obj, error in
            guard let image = obj as? UIImage else { return }
            
            DispatchQueue.main.async {
                self?.profileImageView.image = image
                self?.pickedImageRelay.accept(image)
            }
        }
    }
}
