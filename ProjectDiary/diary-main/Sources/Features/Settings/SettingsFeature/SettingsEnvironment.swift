//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

import Foundation
import UIKit
import ComposableArchitecture
import CoreDataClient
import FileClient
import UserDefaultsClient
import LocalAuthenticationClient
import UIApplicationClient
import AVCaptureDeviceClient
import FeedbackGeneratorClient
import AVAudioSessionClient
import StoreKitClient
import PDFKitClient

public struct SettingsEnvironment {
    public let fileClient: FileClient
    public let userDefaultsClient: UserDefaultsClient
    public let localAuthenticationClient: LocalAuthenticationClient
    public let applicationClient: UIApplicationClient
    public let avCaptureDeviceClient: AVCaptureDeviceClient
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let avAudioSessionClient: AVAudioSessionClient
    public let storeKitClient: StoreKitClient
    public let pdfKitClient: PDFKitClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    public let date: () -> Date
    public let setUserInterfaceStyle: (UIUserInterfaceStyle) -> Effect<Never, Never>
    
    public init(
        fileClient: FileClient,
        userDefaultsClient: UserDefaultsClient,
        localAuthenticationClient: LocalAuthenticationClient,
        applicationClient: UIApplicationClient,
        avCaptureDeviceClient: AVCaptureDeviceClient,
        feedbackGeneratorClient: FeedbackGeneratorClient,
        avAudioSessionClient: AVAudioSessionClient,
        storeKitClient: StoreKitClient,
        pdfKitClient: PDFKitClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>,
        date: @escaping () -> Date,
        setUserInterfaceStyle: @escaping (UIUserInterfaceStyle) -> Effect<Never, Never>
    ) {
        self.fileClient = fileClient
        self.userDefaultsClient = userDefaultsClient
        self.localAuthenticationClient = localAuthenticationClient
        self.applicationClient = applicationClient
        self.avCaptureDeviceClient = avCaptureDeviceClient
        self.feedbackGeneratorClient = feedbackGeneratorClient
        self.avAudioSessionClient = avAudioSessionClient
        self.storeKitClient = storeKitClient
        self.pdfKitClient = pdfKitClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.date = date
        self.setUserInterfaceStyle = setUserInterfaceStyle
    }
}
