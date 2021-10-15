//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 15/10/21.
//

import ComposableArchitecture
import CloudKitClient
import CloudKit

extension CloudKitClient {
    public static let live = Self(
        isCloudAvailable: {
            print(FileManager.default.ubiquityIdentityToken != nil)
            return Effect(value: FileManager.default.ubiquityIdentityToken != nil)
        },
        cloudStatus: {
            .future { callback in
                CKContainer.default().accountStatus { status, error in
                    print(status)
                    switch status {
                    case .available:
                        callback(.success(.available))
                    case .restricted:
                        callback(.success(.restricted))
                    case .noAccount:
                        callback(.success(.noAccount))
                    case .couldNotDetermine, .temporarilyUnavailable:
                        fallthrough
                    @unknown default:
                        callback(.success(.couldNotDetermine))
                    }
                }
            }
        }
    )
}
