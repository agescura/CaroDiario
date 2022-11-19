//
//  File 2.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

import Foundation
import ComposableArchitecture
import Models

extension Reducer where State == RootState, Action == RootAction, Environment == RootEnvironment {
    struct CoreDataId: Hashable {}
    
    public func coreData() -> Reducer<RootState, RootAction, RootEnvironment> {
        return .init { state, action, environment in
            let effects = self.run(&state, action, environment)
            
            if case .home = state.featureState {
                switch action {
                case .featureAction(.home(.entries(.onAppear))):
                    return .merge(
                        environment.coreDataClient.create(CoreDataId())
                            .receive(on: environment.mainQueue)
                            .eraseToEffect()
                            .map({ RootAction.featureAction(.home(.entries(.coreDataClientAction($0)))) }),
                        effects
                    )
                case let .featureAction(.home(.entries(.remove(entry)))):
                    return environment.coreDataClient.removeEntry(entry.id)
                        .fireAndForget()
                    
                case .featureAction(.home(.settings(.exportAction(.processPDF)))):
                    return .merge(
                        environment.coreDataClient.fetchAll()
                            .map({ RootAction.featureAction(.home(.settings(.exportAction(.generatePDF($0))))) }),
                        effects
                    )
                    
                case .featureAction(.home(.settings(.exportAction(.previewPDF)))):
                    return .merge(
                        environment.coreDataClient.fetchAll()
                            .map({ RootAction.featureAction(.home(.settings(.exportAction(.generatePreview($0))))) }),
                        effects
                    )
                    
                case let .featureAction(.home(.search(.searching(newText: newText)))):
                    return .merge(
                        environment.coreDataClient.searchEntries(newText)
                            .map({ RootAction.featureAction(.home(.search(.searchResponse($0)))) }),
                        effects
                    )
                case .featureAction(.home(.search(.navigateImageSearch))):
                    return .merge(
                        environment.coreDataClient.searchImageEntries()
                            .map({ RootAction.featureAction(.home(.search(.navigateSearch(.images, $0)))) }),
                        effects
                    )
                case .featureAction(.home(.search(.navigateVideoSearch))):
                    return .merge(
                        environment.coreDataClient.searchVideoEntries()
                            .map({ RootAction.featureAction(.home(.search(.navigateSearch(.videos, $0)))) }),
                        effects
                    )
                case .featureAction(.home(.search(.navigateAudioSearch))):
                    return .merge(
                        environment.coreDataClient.searchAudioEntries()
                            .map({ RootAction.featureAction(.home(.search(.navigateSearch(.audios, $0)))) }),
                        effects
                    )
                case let .featureAction(.home(.search(.remove(entry)))):
                    return .merge(
                        environment.coreDataClient.removeEntry(entry.id)
                            .fireAndForget(),
                        effects
                    )
                case let .featureAction(.home(.search(.entryDetailAction(.remove(entry))))):
                    return .merge(
                        environment.coreDataClient.removeEntry(entry.id)
                            .fireAndForget(),
                        effects
                    )
                default:
                    break
                }
            }
            
            if case let .home(homeState) = state.featureState,
               let entryDetailState = homeState.entriesState.entryDetailState {
                switch action {
                case .featureAction(.home(.entries(.entryDetailAction(.onAppear)))):
                    return .merge(
                        environment.coreDataClient.fetchEntry(entryDetailState.entry)
                            .map({ RootAction.featureAction(.home(.entries(.entryDetailAction(.entryResponse($0))))) }),
                        effects
                    )
                case let .featureAction(.home(.entries(.entryDetailAction(.removeAttachmentResponse(id))))):
                    return .merge(
                        environment.coreDataClient.removeAttachmentEntry(id).fireAndForget(),
                        effects
                    )
                default:
                    break
                }
            }
            
            if case let .home(homeState) = state.featureState,
               let addEntryState = homeState.entriesState.addEntryState ?? homeState.entriesState.entryDetailState?.addEntryState {
                switch action {
                case .featureAction(.home(.entries(.addEntryAction(.createDraftEntry)))),
                    .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.createDraftEntry))))):
                    return .merge(
                        environment.coreDataClient.createDraft(addEntryState.entry)
                            .fireAndForget(),
                        effects
                    )
                case .featureAction(.home(.entries(.addEntryAction(.addButtonTapped)))),
                    .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.addButtonTapped))))):
                    let entryText = EntryText(
                        id: environment.uuid(),
                        message: addEntryState.text,
                        lastUpdated: environment.date()
                    )
                    return .merge(
                        environment.coreDataClient.updateMessage(entryText, addEntryState.entry)
                            .fireAndForget(),
                        environment.coreDataClient.publishEntry(addEntryState.entry)
                            .fireAndForget(),
                        effects
                    )
                case let .featureAction(.home(.entries(.addEntryAction(.loadImageResponse(entryImage))))),
                    let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.loadImageResponse(entryImage)))))):
                    return .merge(
                        environment.coreDataClient.addAttachmentEntry(entryImage, addEntryState.entry.id)
                            .fireAndForget(),
                        effects
                    )
                case let .featureAction(.home(.entries(.addEntryAction(.loadVideoResponse(entryVideo))))),
                    let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.loadVideoResponse(entryVideo)))))):
                    return .merge(
                        environment.coreDataClient.addAttachmentEntry(entryVideo, addEntryState.entry.id)
                            .fireAndForget(),
                        effects
                    )
                case let .featureAction(.home(.entries(.addEntryAction(.loadAudioResponse(entryAudio))))),
                    let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.loadAudioResponse(entryAudio)))))):
                    return .merge(
                        environment.coreDataClient.addAttachmentEntry(entryAudio, addEntryState.entry.id)
                            .fireAndForget(),
                        effects
                    )
                case let .featureAction(.home(.entries(.addEntryAction(.removeAttachmentResponse(id))))),
                    let .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.removeAttachmentResponse(id)))))):
                    return .merge(
                        environment.coreDataClient.removeAttachmentEntry(id)
                            .fireAndForget(),
                        effects
                    )
                case .featureAction(.home(.entries(.addEntryAction(.removeDraftEntryDismissAlert)))),
                    .featureAction(.home(.entries(.entryDetailAction(.addEntryAction(.removeDraftEntryDismissAlert))))):
                    return .merge(
                        environment.coreDataClient.removeEntry(addEntryState.entry.id)
                            .fireAndForget(),
                        effects
                    )
                default:
                    break
                }
            }
            return effects
        }
    }
}
