//
//  SendTextMessageAutomation.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/14/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK
import SwiftyJSON

/*
 if somebody call this method,
 a getThread request will send
 */

class SendTextMessageAutomation {
    
    
    public weak var delegate: MoreInfoDelegate?
    
    
    let content:        String?
    let metaData:       JSON?
    let repliedTo:      Int?
    let systemMetadata: JSON?
    let threadId:       Int?
    let typeCode:       String?
    let uniqueIdOfAllRequests:  String?
    
    typealias callbackStringTypeAlias           = (String) -> ()
    typealias callbackServerResponseTypeAlias   = (JSON) -> ()
    
    private var uniqueIdCallback:       callbackStringTypeAlias?
    private var serverSentResponse:     callbackServerResponseTypeAlias?
    private var serverDeliverResponse:  callbackServerResponseTypeAlias?
    private var serverSeenResponse:     callbackServerResponseTypeAlias?
    
    init(content: String?, metaData: JSON?, repliedTo: Int?, systemMetadata: JSON?, threadId: Int?, typeCode: String?, uniqueId: String?) {
        
        self.content        = content
        self.metaData       = metaData
        self.repliedTo      = repliedTo
        self.systemMetadata = systemMetadata
        self.threadId       = threadId
        self.typeCode       = typeCode
        self.uniqueIdOfAllRequests = uniqueId
    }
    
    func create(uniqueId:               @escaping (String) -> (),
                serverSentResponse:     @escaping (JSON) -> (),
                serverDeliverResponse:  @escaping (JSON) -> (),
                serverSeenResponse:     @escaping (JSON) -> ()) {
        
        self.uniqueIdCallback       = uniqueId
        self.serverSentResponse     = serverSentResponse
        self.serverDeliverResponse  = serverDeliverResponse
        self.serverSeenResponse     = serverSeenResponse
        
        switch (content, threadId) {
        case let (.some(myContent), .some(myThreadId)):
            sendRequest(theContent: myContent, theMetaData: metaData, theRepliedTo: repliedTo, theSystemMetadata: systemMetadata, theThreadId: myThreadId, theTypeCode: typeCode, theUniqueId: uniqueIdOfAllRequests)
        case let (.some(myContent), .none):
            // here we have to create a thread, then send a message to this thread Id
            createThreadAndSendMessage(withContent: myContent)
        case let (.none, .some(myThreadId)):
            // here we have to generate a custom message to send, then send a message to this thread Id
            let text = Faker.sharedInstance.generateNameAsString(withLength: 30)
            sendRequest(theContent: text, theMetaData: metaData, theRepliedTo: repliedTo, theSystemMetadata: systemMetadata, theThreadId: myThreadId, theTypeCode: typeCode, theUniqueId: uniqueIdOfAllRequests)
        default:
            delegate?.newInfo(type: MoreInfoTypes.SendTextMessage.rawValue, message: "You have to fill the  Content(iput 1) and threadId(input 3) of the message", lineNumbers: 2)
            createThreadAndSendMessage(withContent: nil)
        }
        
        if (content == nil) || (threadId == nil) {
            
        }
        
    }
    
    
    func sendRequest(theContent: String, theMetaData: JSON?, theRepliedTo: Int?, theSystemMetadata: JSON?, theThreadId: Int, theTypeCode: String?, theUniqueId: String?) {
        
        delegate?.newInfo(type: MoreInfoTypes.GetThread.rawValue, message: "send Request to SendTextMesssage with this params:\ncount = \(theContent) , metaData = \(theMetaData ?? JSON.null) , repliedTo = \(theRepliedTo ?? 0) , systemMetadata = \(theSystemMetadata ?? JSON.null) , threadId = \(theThreadId) , typeCode = \(theTypeCode ?? "nil") , uniqueId = \(theUniqueId ?? "nil")", lineNumbers: 2)
        
        let sendTextMessage = SendTextMessageRequestModel(content:          theContent,
                                                          metaData:         theMetaData,
                                                          repliedTo:        theRepliedTo,
                                                          systemMetadata:   theSystemMetadata,
                                                          threadId:         theThreadId,
                                                          typeCode:         theTypeCode,
                                                          uniqueId:         theUniqueId)
        myChatObject?.sendTextMessage(sendTextMessageInput: sendTextMessage, uniqueId: { (sentTextMessageUniqueId) in
            self.uniqueIdCallback?(sentTextMessageUniqueId)
        }, onSent: { (sent) in
            self.serverSentResponse?(sent as! JSON)
        }, onDelivere: { (deliver) in
            self.serverDeliverResponse?(deliver as! JSON)
        }, onSeen: { (seen) in
            self.serverSeenResponse?(seen as! JSON)
        })
        
        
    }
    
    
    func createThreadAndSendMessage(withContent: String?) {
        
        delegate?.newInfo(type: MoreInfoTypes.SendTextMessage.rawValue, message: "try to addContact, then create a thread with it, then send a message to it", lineNumbers: 1)
        
        let pouria = Faker.sharedInstance.pouriaAsContact
        
        let addContact = AddContactAutomation(cellphoneNumber: pouria.cellphoneNumber, email: nil, firstName: pouria.firstName, lastName: pouria.lastName)
        addContact.create(uniqueId: { _ in }) { (contactModel) in
            if let myContact = contactModel.contacts.first {
                if let cellphoneNumber = myContact.cellphoneNumber {
                    
                    let fakeParams = Faker.sharedInstance.generateFakeCreateThread()
                    
                    self.delegate?.newInfo(type: MoreInfoTypes.SendTextMessage.rawValue, message: "New Contact has been created, now try to create thread with some fake params and this CellphoneNumber = \(cellphoneNumber).", lineNumbers: 2)
                    
                    let myInvitee = Invitee(id: "\(cellphoneNumber)", idType: "\(InviteeVOidTypes.TO_BE_USER_CELLPHONE_NUMBER)")
                    
                    let createThread = CreateThreadAutomation(description: fakeParams.description, image: nil, invitees: [myInvitee], metadata: nil, title: fakeParams.title, type: self.typeCode, requestUniqueId: nil)
                    
                    createThread.create(uniqueId: { (_, _) in }, serverResponse: { (createThreadModel, _) in
                        
                        if let id = createThreadModel.thread?.id {
                            self.delegate?.newInfo(type: MoreInfoTypes.SendTextMessage.rawValue, message: "new Thread has been created, threadId = \(id)", lineNumbers: 1)
                            
                            self.sendRequest(theContent: withContent ?? "This is a dummy message", theMetaData: self.metaData, theRepliedTo: self.repliedTo, theSystemMetadata: self.systemMetadata, theThreadId: id, theTypeCode: self.typeCode, theUniqueId: self.uniqueIdOfAllRequests)
                        }
                    })
                    
                } else {
                    // handle error that didn't get contact id in the contact model
                    self.delegate?.newInfo(type: MoreInfoTypes.SendTextMessage.rawValue, message: "there is no CellphoneNumber when addContact with this user (firstName = \(pouria.firstName) , cellphoneNumber = \(pouria.cellphoneNumber))!", lineNumbers: 2)
                }
            } else {
                // handle error that didn't add Contact Model
                self.delegate?.newInfo(type: MoreInfoTypes.SendTextMessage.rawValue, message: "AddContact with this parameters is Failed!\nfirstName = \(pouria.firstName) , cellphoneNumber = \(pouria.cellphoneNumber) , lastName = \(pouria.lastName)", lineNumbers: 2)
            }
        }
        
    }
    
    
}
