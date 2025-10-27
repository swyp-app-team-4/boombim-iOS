//
//  ProfileViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

final class ProfileViewController: BaseViewController {
    private let viewModel: ProfileViewModel
    private let disposeBag = DisposeBag()
    
    // 이미지 선택 값을 담아 ViewModel로 전달
    private let pickedImageRelay = BehaviorRelay<UIImage?>(value: nil)
    // ✅ 추가: 약관 동의 완료 후에만 ViewModel로 실제 가입을 트리거
    private let proceedRegisterRelay = PublishRelay<Void>()
    
    // MARK: - UI
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
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
        label.setText("nickname.label.nickname".localized(), style: Typography.Body03.regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        
        return label
    }()
    
    private let nicknameTextField: KoreanOnlyTextField = {
        let textField = KoreanOnlyTextField()
        textField.maxLength = 10
        
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
    
    private let nicknameSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale7
        label.setText("profile.label.subtitle".localized(), style: Typography.Caption.regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        
        return label
    }()
    
    private let nicknameValidateSuccess: UILabel = {
        let label = UILabel()
        label.textColor = .validateSuccess
        label.setText("profile.label.validate.success".localized(), style: Typography.Caption.regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        
        return label
    }()
    
    private let nicknameValidateFail: UILabel = {
        let label = UILabel()
        label.textColor = .validateFail
        label.setText("profile.label.validate.fail".localized(), style: Typography.Caption.regular)
        label.textAlignment = .left
        label.numberOfLines = 2
        
        return label
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.grayScale4
        button.setTitle( "profile.label.register".localized(), for: .normal)
        button.setTitleColor(.grayScale7, for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.layer.cornerRadius = 10
        
        return button
    }()

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "프로필 관리"
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
        view.backgroundColor = .background
        
        setupNavigationBar()
        
        configureImageView()
        configureTextField()
        configureButton()
        
        bind()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .grayScale9
//        navigationController?.navigationBar.topItem?.title = ""
    }
    
    private func configureImageView() {
        [profileImageView, cameraButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        let profileImageViewDiameter: CGFloat = 118
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
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
        [textFieldTitleLabel, nicknameTextField, nicknameSubtitleLabel, nicknameValidateSuccess, nicknameValidateFail].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            textFieldTitleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            textFieldTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nicknameTextField.topAnchor.constraint(equalTo: textFieldTitleLabel.bottomAnchor, constant: 6),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nicknameTextField.heightAnchor.constraint(equalToConstant: 46),
            
            nicknameSubtitleLabel.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 6),
            nicknameSubtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nicknameSubtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nicknameValidateSuccess.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 6),
            nicknameValidateSuccess.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nicknameValidateSuccess.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nicknameValidateFail.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 6),
            nicknameValidateFail.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nicknameValidateFail.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func configureButton() {
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(registerButton)
        
        NSLayoutConstraint.activate([
            registerButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            registerButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Binding
    private func bind() {
        // MARK: - Inputs & Outputs
        let appear = rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in () }
            .asSignal(onErrorSignalWith: .empty())

        let input = ProfileViewModel.Input(
            appear: appear,
            nicknameText: nicknameTextField.rx.text.orEmpty.asDriver(),
            pickedImage: pickedImageRelay.asDriver(),
            registerTap: proceedRegisterRelay.asSignal()
        )

        let output = viewModel.transform(input: input)

        // Reusable derived streams
        let isEmptyText = nicknameTextField.rx.text.orEmpty
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: true)

        let isValid = output.isRegisterEnabled
            .asDriver(onErrorJustReturn: false)

        // MARK: - Global/Loading State
        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        output.isLoading
            .map { !$0 }
            .drive(onNext: { [weak self] enabled in
                self?.nicknameTextField.isEnabled = enabled
                self?.cameraButton.isEnabled = enabled
            })
            .disposed(by: disposeBag)

        output.error
            .emit(onNext: { [weak self] msg in
                self?.presentAlert(title: "오류", message: msg)
            })
            .disposed(by: disposeBag)

        // MARK: - UI Population
        output.profile
            .drive(onNext: { [weak self] profile in
                guard let self else { return }
                self.nicknameTextField.text = profile.name
                self.profileImageView.setImage(from: profile.profile)
            })
            .disposed(by: disposeBag)

        let placeholder = UIImage.iconEmptyProfile
        pickedImageRelay
            .asDriver()
            .map { $0 ?? placeholder }
            .drive(profileImageView.rx.image)
            .disposed(by: disposeBag)

        // MARK: - Validation Hints
        isEmptyText
            .map { !$0 }
            .drive(nicknameSubtitleLabel.rx.isHidden)
            .disposed(by: disposeBag)

        Driver.combineLatest(isEmptyText, isValid)
            .map { isEmpty, valid in !( !isEmpty && valid ) }
            .drive(nicknameValidateSuccess.rx.isHidden)
            .disposed(by: disposeBag)

        Driver.combineLatest(isEmptyText, isValid)
            .map { isEmpty, valid in !( !isEmpty && !valid ) }
            .drive(nicknameValidateFail.rx.isHidden)
            .disposed(by: disposeBag)

        // MARK: - Button Enable/Style
        Driver.combineLatest(output.isRegisterEnabled, output.isLoading.map { !$0 }) { $0 && $1 }
            .drive(onNext: { [weak self] isEnabled in
                self?.registerButton.isEnabled = isEnabled
                if isEnabled {
                    self?.registerButton.backgroundColor = .main
                    self?.registerButton.setTitleColor(.grayScale1, for: .normal)
                } else {
                    self?.registerButton.backgroundColor = .grayScale4
                    self?.registerButton.setTitleColor(.grayScale7, for: .normal)
                }
            })
            .disposed(by: disposeBag)

        // MARK: - User Actions
        registerButton.rx.tap
            .withLatestFrom(output.isRegisterEnabled)
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.view.endEditing(true)
                self.proceedRegisterRelay.accept(())
            })
            .disposed(by: disposeBag)

        // MARK: - Navigation/Completion
        viewModel.registerCompleted
            .emit(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Action
    private func setupActions() {
        setupTextFieldActions()
        setupCameraButtonAction()
    }
    
    private func setupTextFieldActions() {
        nicknameTextField.addTarget(self, action: #selector(textFieldEditingBegan), for: .editingDidBegin)
        nicknameTextField.addTarget(self, action: #selector(textFieldEditingEnded), for: .editingDidEnd)
    }
    
    @objc private func textFieldEditingBegan(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.grayScale7.cgColor
    }

    @objc private func textFieldEditingEnded(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.grayScale4.cgColor
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
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {

    // MARK: - Public Entrypoints
    func showCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentSimpleAlert(title: "카메라 사용 불가",
                               message: "이 기기에서는 카메라를 사용할 수 없습니다.")
            return
        }
        checkCameraPermission { [weak self] granted in
            guard let self else { return }
            granted ? self.presentCamera() :
                      self.presentSettingsAlert(title: "카메라 권한 필요",
                                               message: "설정 > 개인정보 보호 > 카메라에서 권한을 허용해 주세요.")
        }
    }

    func showPhotoPicker(selectionLimit: Int = 1) {
        checkPhotoPermission { [weak self] granted in
            guard let self else { return }
            if granted {
                var config = PHPickerConfiguration(photoLibrary: .shared())
                config.filter = .images
                config.selectionLimit = selectionLimit // 1: 단일, 0: 무제한
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = self
                self.present(picker, animated: true)
            } else {
                self.presentSettingsAlert(title: "앨범 접근 권한 필요",
                                          message: "설정 > 개인정보 보호 > 사진에서 권한을 허용해 주세요.")
            }
        }
    }

    // MARK: - Permission Checks
    private func checkCameraPermission(_ completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        default:
            completion(false)
        }
    }

    private func checkPhotoPermission(_ completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        default:
            completion(false)
        }
    }

    // MARK: - Presenters
    private func presentCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Alerts
    private func presentSettingsAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default, handler: { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        present(alert, animated: true)
    }

    private func presentSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        picker.dismiss(animated: true) { [weak self] in
            guard let self, let image else { return }
            self.profileImageView.image = image
            self.pickedImageRelay.accept(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    // MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] obj, _ in
            guard let image = obj as? UIImage else { return }
            DispatchQueue.main.async {
                self?.profileImageView.image = image
                self?.pickedImageRelay.accept(image)
            }
        }
    }
}
