//
//  SharedFormView.swift
//
//  Created by vince on 02/08/2024.
//
import SwiftUI
import CoreBluetooth
import BLEReaderUtility

struct SharedFormView<Content:View>: View {
    
    @Environment(ReaderListModel.self) private var readerListModel
    @Environment(ReaderManager.self) private var readerManager
    @Environment(AlertHandling.self) private var alertHandling

    @State private var readerSettings:ReaderSettings
    @State private var isResetting:Bool = false
    
    private var content: () -> Content
    
    init(_ readerSettings:ReaderSettings, @ViewBuilder content: @escaping () -> Content) {
        self.readerSettings = readerSettings
        self.content = content
    }
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                
                Section {
                    DeviceTypeView(type: $readerSettings.deviceType)
                        .onChange(of: readerSettings.deviceType) { _, deviceType in
                            readerManager.characteristicSetter(.deviceType(deviceType))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.readerListModel.disconnect()
                            }
                        }
                }
                .expandSection()
                
                content()
                
                Section {
                    AlertBtn(btnTitle: BLEReaderProperties.newPassword.title,
                             alertTitle:BLEReaderUI.configuration.title,
                             placeholder: BLEReaderUI.password.title) { password in
                        readerManager.characteristicSetter(.newPassword(password))
                    }
                }
                .expandSection(.blue)
                
                Section {
                    Button {
                        let reset = CustomAlert.resetAlert {
                            isResetting = true
                            readerManager.characteristicSetter(.reset(readerSettings.deviceType))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.readerListModel.disconnect()
                            }
                        }
                        alertHandling.handle(reset)
                        
                    } label: {
                        Text("Factory settings")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .expandSection(.red)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .navigationBarItems(leading: CloseBtn())
            .toolbar {
                ToolbarItem(placement: .principal) {
                    CustomAlertBtn(alertTitle: BLEReaderProperties.deviceName.title, placeholder: BLEReaderProperties.deviceName.title, action: { deviceName in
                        readerSettings.deviceName = deviceName
                        readerManager.characteristicSetter(.deviceName(deviceName))
                    }) {
                        Text(readerSettings.deviceName)
                            .fontWeight(.semibold)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
        .disabled(isResetting)
        .overlay {
            if isResetting {
                Rectangle()
                    .fill(.black.opacity(0.4))
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                    }
            }
        }
    }
    
    @ViewBuilder
    private func CloseBtn() -> some View {
        Button("", systemImage: "xmark") {
            let customAlert = CustomAlert.logout {
                readerListModel.disconnect()
            }
            alertHandling.handle(customAlert)
        }
    }
}
