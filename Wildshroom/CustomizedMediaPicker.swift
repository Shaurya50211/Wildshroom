//
//  Created by Alex.M on 05.07.2022.
//

import Foundation
import SwiftUI
import MediaPicker

struct CustomizedMediaPicker: View {

    @EnvironmentObject private var appDelegate: AppDelegate

    @Binding var isPresented: Bool
    @Binding var medias: [Media]

    @State private var selectedMedia: [Media] = []
    @State private var albums: [Album] = []

    @State private var mediaPickerMode = MediaPickerMode.photos
    @State private var selectedAlbum: Album?
    @State private var showAlbumsDropDown: Bool = false

    let maxCount: Int = 1

    var body: some View {
        MediaPicker(
            isPresented: $isPresented,
            limit: maxCount,
            orientationHandler: {
                switch $0 {
                case .lock: appDelegate.lockOrientationToPortrait()
                case .unlock: appDelegate.unlockOrientation()
                }
            },
            onChange: { selectedMedia = $0 },
            albumSelectionBuilder: { _, albumSelectionView in
                VStack {
                    headerView
                    albumSelectionView
                    Spacer()
                    footerView
                }
                .background(Color.black)
            },
            cameraSelectionBuilder: { addMoreClosure, cancelClosure, cameraSelectionView in
                VStack {
                    HStack {
                        Spacer()
                        Button("Done", action: {
                            isPresented = false
                            medias = selectedMedia
                        })
                    }
                    cameraSelectionView
                    HStack {
                        Button("Cancel", action: cancelClosure)
                        Spacer()
                        Button(action: addMoreClosure) {
                            Text("Take more photos")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                        }
                        .background {
                            Color("CustomGreen")
                                .cornerRadius(16)
                        }
                    }
                }
                .background(Color.black)
            }
        )
        .showLiveCameraCell()
        .albums($albums)
        .pickerMode($mediaPickerMode)
        .selectionStyle(.count)
        .mediaPickerTheme(
            main: .init(
                albumSelectionBackground: .black,
                fullscreenPhotoBackground: .black
            ),
            selection: .init(
                emptyTint: .white,
                emptyBackground: .black.opacity(0.25),
                selectedTint: Color("CustomPurple"),
                fullscreenTint: .white
            )
        )
        .overlay(alignment: .topLeading) {
            if showAlbumsDropDown {
                albumsDropdown
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(5)
            }
        }
        .background(Color.black)
        .foregroundColor(.white)
    }

    var headerView: some View {
        HStack {
            HStack {
                Text(selectedAlbum?.title ?? "Recents")
                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(radians: showAlbumsDropDown ? .pi : 0))
            }
            .onTapGesture {
                withAnimation {
                    showAlbumsDropDown.toggle()
                }
            }

            Spacer()

            Text("\(selectedMedia.count) out of \(maxCount) selected")
        }
        .padding()
    }

    var footerView: some View {
        HStack {
            Button {
                isPresented = false
            } label: {
                Text("Cancel")
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer(minLength: 70)

            Button {
                medias = selectedMedia
                isPresented = false
            } label: {
                HStack {
                    Text("Add")

                    Text("\(selectedMedia.count)")
                        .padding(6)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
            }
            .background {
                Color("CustomGreen")
                    .cornerRadius(16)
            }
        }
        .padding(.horizontal)
    }

    var albumsDropdown: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(albums) { album in
                    Button(album.title ?? "") {
                        selectedAlbum = album
                        mediaPickerMode = .album(album)
                        showAlbumsDropDown = false
                    }
                }
            }
            .padding(15)
        }
        .frame(maxHeight: 300)
    }
}
