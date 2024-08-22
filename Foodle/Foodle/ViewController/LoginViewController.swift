//
//  LoginViewCell.swift
//  Foodle
//
//  Created by 민정 on 3/19/24.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon

class LoginViewController: UIViewController {
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var loginLabel2: UILabel!
    @IBOutlet var kakaoButton: UIButton!
    @IBOutlet var naverButton: UIButton!
    @IBOutlet var appleButton: UIButton!
    @IBOutlet var privacyLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PrivacyLabel에 밑줄 추가
        let attributedString = NSMutableAttributedString(string: "개인정보 이용 처리 방침")
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        privacyLabel.attributedText = attributedString
        
        // '프들'만 볼드체로 변경
        if let labelText = loginLabel.text {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: loginLabel.font.pointSize), range: NSRange(location: 0, length: 2)) // 첫 번째 글자와 두 번째 글자에 적용
            loginLabel.attributedText = attributedString
        }
        
        // 카카오 버튼 액션 연결
        kakaoButton.addTarget(self, action: #selector(handleKakaoLogin), for: .touchUpInside)

        // 로그아웃 버튼 액션 연결
        logoutButton.addTarget(self, action: #selector(handleKakaoLogout), for: .touchUpInside)
    }

    // 카카오톡 로그인 버튼을 눌렀을 때 실행되는 메서드
    @objc func handleKakaoLogin() {
        // 카카오톡 실행 가능 여부 확인
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    print(error)
                } else {
                    print("loginWithKakaoTalk() success.")
                    // 사용자 정보 가져오기
                    self.kakaoGetUserInfo()
                }
            }
        } else {
            // 카카오톡이 설치되지 않았을 경우 웹 로그인을 진행할 수 있도록 처리
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print(error)
                } else {
                    print("loginWithKakaoAccount() success.")
                    // 사용자 정보 가져오기
                    self.kakaoGetUserInfo()
                }
            }
        }
        toLaunch()
    }
    
    private func toLaunch(){
        let storyboard = UIStoryboard(name: "Jinhee", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LaunchVC")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }

    @IBAction func naverLogin(_ sender: Any) {
        NaverSNSLogin.shared.login(){
        }
        toLaunch()
    }
    
    // 사용자 정보 가져오기
    private func kakaoGetUserInfo() {
        UserApi.shared.me { (user, error) in
            if let error = error {
                print(error)
            } else {
                guard let user = user else { return }

                guard let id = user.id else { return }
                
                let uid = String(id)
                let profileImage = user.kakaoAccount?.profile?.profileImageUrl?.absoluteString ?? ""
                let nickname = user.kakaoAccount?.profile?.nickname ?? ""

                let userInfo = User(uid: uid, profileImage: profileImage, name: nickname, nickName: nickname)
                
                fetchUser(uid) { result in
                    if let result = result {
                        self.user = result
                        print("Existing user: \(result)")
                    } else {
                        createUser(userInfo) {
                            guard let uid = userInfo.uid else { return }
                            fetchUser(uid) { result in
                                self.user = result
                                print("Created new user: \(String(describing: result))")
                            }
                        }
                    }
                }
            }
        }
    }

    // 로그아웃 버튼을 눌렀을 때 실행되는 메서드
    @objc private func handleKakaoLogout() {
        UserApi.shared.logout { (error) in
            if let error = error {
                print(error)
            } else {
                print("logout() success.")
            }
        }
    }
}
