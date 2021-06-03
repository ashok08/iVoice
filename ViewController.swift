//
//  ViewController.swift
//  iVoice
//
//  Created by Ashok on 31/05/21.
//

import UIKit
import AgoraRtcKit
import AgoraRtmKit

//MARK: - GlobalVariables
var appId =  "YOUR_APP_ID"
var isSpeaker = false
var username  =  String()
var token  =  String()
var userRole : AgoraClientRole!
var agoraKit : AgoraRtcEngineKit?
var agoraRTMkit :  AgoraRtmKit?
var agoraRTMchannel : AgoraRtmChannel?
var room =  String()
var uniqueID: UInt = 0
var speakers: Set<UInt> = []
var audiences: Set<UInt> = []
var allUsers: [UInt: String] = [:]

//MARK: - MainViewController
class ViewController: UIViewController {
    
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var audienceBtn: UIButton!
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.audienceBtn.dropShadows(radius: 5, color: UIColor.lightGray)
        self.speakerBtn.dropShadows(radius: 5, color: UIColor.lightGray)
        self.audienceBtn.layer.cornerRadius = 65
        self.speakerBtn.layer.cornerRadius = 65
        
    }
    //MARK: - BtnActions
    @IBAction func actionBtn(_ sender: UIButton) {
        let joinVC = Utilities.shared.instantiateViewController("Main", "JoinViewController", ofClass: JoinViewController.self)
        isSpeaker = sender.tag == 0 ? false : true
        self.present(joinVC, animated: true, completion: nil)
    }
    
}

//MARK: - JoinViewController
class JoinViewController: UIViewController {
    
    @IBOutlet weak var channelTxtField: UITextField!
    @IBOutlet weak var userTxtField: UITextField!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var joinBtn: UIButton!

    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLbl.text = isSpeaker ? "I'm a Speaker" : "I'm a Audience"
        self.joinBtn.setTitle(isSpeaker ? "Create" : "Join", for: .normal)
        userRole = isSpeaker ? .broadcaster : .audience
        agoraRTMkit = AgoraRtmKit(appId: appId, delegate: self)
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: appId, delegate: self)
        agoraKit?.enableAudio()
        agoraKit?.enableAudioVolumeIndication(1000, smooth: 3, report_vad: true)
        agoraKit?.setChannelProfile(.liveBroadcasting)
        agoraKit?.setClientRole(userRole)
    }
    
    //MARK: - JoinBtnTapped
    @IBAction func joinBtn(_ sender: UIButton) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.view.endEditing(true)
                Utilities.shared.showLoader(view: self.view)
                room = self.channelTxtField.text ?? ""
                username = self.userTxtField.text ?? ""
                self.connectChannel()
            }
        }
    }
    //MARK: - ConnectToChannel
    func connectChannel() {
        agoraRTMkit?.login(byToken: token, user: username)
        agoraRTMchannel = agoraRTMkit?.createChannel(withId: room, delegate: self)
        self.joinChannel()
        
    }
    //MARK: - JoinChannel
    func joinChannel() {
        agoraKit?.joinChannel( byToken: token, channelId: room,  info: nil, uid: uniqueID, joinSuccess: { (_, uid, elapsed) in
            uniqueID = uid
            
            if userRole == .audience {
            audiences.insert(uid)
            } else {
            speakers.insert(uid)
            }
            allUsers[uid] = username
            
            Utilities.shared.hideLoader()
            self.callLeaveViewController()
            
            agoraRTMchannel?.join(completion: { (errcode) in
                if errcode == .channelErrorOk{
                    self.sendJoinedUser(userName: username)
                }
            })
        }
        )
    }
    
    //MARK: - sendJoinedUser
    func sendJoinedUser(userName: String?) {
        if let user = userName {
            agoraRTMkit?.send(AgoraRtmMessage(text: uniqueID.description), toPeer: user)
        } else {
            agoraRTMchannel?.send(AgoraRtmMessage(text: uniqueID.description))
        }
    }
    
    //MARK: - InitiateLeaveViewController
    func callLeaveViewController(){
        let leaveVC = Utilities.shared.instantiateViewController("Main", "LeaveViewController", ofClass: LeaveViewController.self)
        self.present(leaveVC, animated: true, completion: nil)
    }
    
}


//MARK: - LeaveViewController
class LeaveViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - SendJoinedUser
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    //MARK: - LeaveBtnTapped
    @IBAction func leaveBtn(_ sender: UIButton) {
        if userRole == .audience{
            self.leaveChannel()
        }else{
            self.destroyChannel()
        }
    }
    
    //MARK: - LeaveChannel
    func leaveChannel(){
        agoraRTMchannel?.leave()
        agoraKit?.createRtcChannel(room)?.leave()
        agoraRTMkit?.logout()
        agoraKit?.leaveChannel()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - DestroyChannel
    func destroyChannel(){
        AgoraRtcEngineKit.destroy()
        agoraRTMkit?.destroyChannel(withId: room)
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - UICollectionView Delegate and Datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? speakers.count : audiences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueXib("CardCVCell", indexPath, CardCVCell.self)
        cell.setUI(index: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width/2) - 10, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}



//MARK: - Extension JoinController
extension JoinViewController: AgoraRtcEngineDelegate {
    func rtcEngine( _ engine: AgoraRtcEngineKit, remoteAudioStateChangedOfUid uid: UInt, state: AgoraAudioRemoteState,reason: AgoraAudioRemoteStateReason, elapsed: Int) {
        
        switch state {
        case .decoding, .starting:
            audiences.remove(uid)
            speakers.insert(uid)
        case .stopped, .failed:
            speakers.remove(uid)
        default:
            return
        }
    }
}

extension JoinViewController: AgoraRtmDelegate, AgoraRtmChannelDelegate {
    
    func channel(_ channel: AgoraRtmChannel, memberJoined member: AgoraRtmMember) {
        if uniqueID > 0 { self.sendJoinedUser(userName: member.userId) }
    }
    func channel(_ channel: AgoraRtmChannel, memberLeft member: AgoraRtmMember) {
        guard let uid = allUsers.first(where: { (keyval) -> Bool in
            keyval.value == member.userId
        })?.key else {
            print("Not found: \(member.userId)")
            return
        }
        audiences.remove(uid)
        speakers.remove(uid)
        allUsers.removeValue(forKey: uid)
    }
    
    func channel(  _ channel: AgoraRtmChannel, messageReceived message: AgoraRtmMessage, from member: AgoraRtmMember) {
        self.memberJoined(message.text, from: member.userId)
    }
    
    func rtmKit( _ kit: AgoraRtmKit,  messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        self.memberJoined(message.text, from: peerId)
    }
    
    func memberJoined(_ message: String, from username: String) {
        if let uidMessage = UInt(message) {
            allUsers[uidMessage] = username
            if !audiences.union(speakers).contains(uidMessage) {
                audiences.insert(uidMessage)
            }
        }
    }
}
