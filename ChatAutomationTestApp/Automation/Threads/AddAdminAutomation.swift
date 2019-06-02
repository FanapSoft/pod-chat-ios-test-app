//
//  AddAdminAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 3/11/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

//import PodChat
import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 GetAdminAutomation request will send
 */

class AddAdminAutomation {
    
    public weak var delegate: MoreInfoDelegate?
    
    let threadId:       Int?
    let userId:         Int?
    let requestUniqueId: String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (JSON) -> ()
    typealias callbackCacheResponseTypeAlias    = (JSON) -> ()
    
    private var uniqueIdCallback:       callbackStringTypeAlias?
    private var serverResponseCallback: callbackServerResponseTypeAlias?
    private var cacheResponseCallback:  callbackCacheResponseTypeAlias?
    
    init(threadId: Int?, userId: Int?, requestUniqueId: String?) {
        
        self.threadId       = threadId
        self.userId         = userId
        self.requestUniqueId = requestUniqueId
        
    }
    
    func create(uniqueId:       @escaping callbackStringTypeAlias,
                serverResponse: @escaping callbackServerResponseTypeAlias,
                cacheResponse:  @escaping callbackCacheResponseTypeAlias) {
        
        self.uniqueIdCallback       = uniqueId
        self.serverResponseCallback = serverResponse
        self.cacheResponseCallback  = cacheResponse
        
        switch (threadId, userId) {
        case let (.some(tId), .some(uId)):
            sendRequest(theThreadId: tId, theUserId: uId)
        default:
            addParticipant()
        }
        
    }
    
    func sendRequest(theThreadId: Int, theUserId: Int) {
        delegate?.newInfo(type: MoreInfoTypes.AddAdmin.rawValue, message: "send Request to getAdmins with this params: \n threadId = \(theThreadId)", lineNumbers: 2)
        
        let addAdminInput = SetRoleRequestModel(roles: [Roles.EDIT_MESSAGE_OF_OTHERS], roleOperation: RoleOperations.Add, threadId: theThreadId, uniqueId: requestUniqueId, userId: theUserId)
        myChatObject?.setRole(setRoleInput: [addAdminInput], uniqueId: { (addAdminUniqueId) in
            self.uniqueIdCallback?(addAdminUniqueId)
        }, completion: { (addAdminServerResponseModel) in
            self.serverResponseCallback?(addAdminServerResponseModel as! JSON)
        }, cacheResponse: { (addAdminCacheResponseModel) in
            self.cacheResponseCallback?(addAdminCacheResponseModel as! JSON)
        })
        
    }
    
    func addParticipant() {
        delegate?.newInfo(type: MoreInfoTypes.AddAdmin.rawValue, message: "Try to create thread then add an participant to the thread", lineNumbers: 2)
        let addParticipant = AddParticipantAutomation(contacts: nil, threadId: nil, typeCode: nil, uniqueId: nil)
        addParticipant.create(uniqueId: { _ in }) { (addParticipantResponseModel) in
            if let threadModel = addParticipantResponseModel.thread {
                if let myThreadId = threadModel.id {
                    if let participants = threadModel.participants {
                        if participants.count > 0 {
//                            self.sendRequest(theThreadId: myThreadId)
                            if let threadParticipants = threadModel.participants {
                                var found = false
                                for item in threadParticipants {
                                    if !found {
                                        switch (item.admin, item.id) {
                                        case let (.none, .some(participantId)):
                                            self.sendRequest(theThreadId: myThreadId, theUserId: participantId)
                                            found = true
                                        case let (.some(isTrue), .some(participantId)):
                                            if !isTrue {
                                                self.sendRequest(theThreadId: myThreadId, theUserId: participantId)
                                                found = true
                                            }
                                        default: return
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        self.delegate?.newInfo(type: MoreInfoTypes.AddAdmin.rawValue, message: "Error: AddParticipant response does not have Participants inside the thread Model!!!!", lineNumbers: 2)
                    }
                } else {
                    self.delegate?.newInfo(type: MoreInfoTypes.AddAdmin.rawValue, message: "Error: AddParticipant response does not have threadId inside the thread Model!!!!", lineNumbers: 2)
                }
            } else {
                self.delegate?.newInfo(type: MoreInfoTypes.AddAdmin.rawValue, message: "Error: AddParticipant response does not have thread model in it!!!!", lineNumbers: 2)
            }
        }
    }
    
    
}