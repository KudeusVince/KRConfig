//
//  MainView.swift
//
//  Created by vince on 11/11/2024.
//

import SwiftUI
import CoreBluetooth
import BLEReaderUtility

struct ContentView: View {
    
    @Environment(ErrorHandling.self) private var errorHandling
    
    @State private var readerListModel: ReaderListModel
    @State private var cbPeripheral: CBPeripheral?
    @State private var selection: BLEReaderType = .deskReader
    
    private let ADMINPASS = "Admin@Kudeus"
    
    init() {
        readerListModel = ReaderListModel(services: [Services.service_device_settings.uuid,
                                                     Services.service_bt_reader.uuid,
                                                     Services.service_kreader.uuid])
    }
    
    var body: some View {
        NavigationStack {
            ReaderListView(readerListModel: readerListModel, bleReaderType: $selection)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Picker("", selection: $selection) {
                            ForEach(BLEReaderType.allCases) { bleReaderType in
                                Text(bleReaderType.title)
                                    .tag(bleReaderType)
                            }
                        }
                        .pickerStyle(.segmented)
                        .fixedSize()
                    }
                }
                .sheet(item: $cbPeripheral) { cbPeripheral in
                    ReaderContainerView(cbPeripheral,
                                        bleReaderType: selection,
                                        properties: selection.adminProperties,
                                        password: ADMINPASS) { readerSettings in
                        SharedFormView(readerSettings) {
                            switch selection {
                            case .deskReader:
                                EditDeskReaderView(readerSettings)
                            case .accessReader:
                                EditAccessReaderView(readerSettings)
                            }
                        }
                    }
                    .errorHandling()
                    .alertHandling()
                }
                .environment(readerListModel)
                .onReceive(readerListModel.peripheralPublisher) { cbPeripheral in
                    self.cbPeripheral = cbPeripheral
                }
                .onReceive(readerListModel.errorPublisher) { error in
                    errorHandling.handle(error: error)
                }
                
        }
    }
}
