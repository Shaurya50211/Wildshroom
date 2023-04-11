import SwiftUI
import MediaPicker
import Combine
import CoreML
import CoreImage.CIImage

struct ContentView: View {
    
    @EnvironmentObject private var appDelegate: AppDelegate
    
    @State private var showCustomizedMediaPicker = false
    
    @State private var medias: [Media] = []
    
    @State private var typeOfMushroom: String = ""
    
    @State private var fgc: Color = .white
    
    let columns = [GridItem(.flexible(), spacing: 1),
                   GridItem(.flexible(), spacing: 1),
                   GridItem(.flexible(), spacing: 1)]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("Pick Mushroom") {
                        showCustomizedMediaPicker = true
                    }
                }
                
                if !medias.isEmpty {
                    Section {
                        LazyVGrid(columns: columns, spacing: 1) {
                            ForEach(medias) { media in
                                MediaCell(media: media)
                                    .aspectRatio(1, contentMode: .fill)
                            }
                        }
                    }
                }
                
                Button {
                    if !medias.isEmpty {
                        do {
                            let config = MLModelConfiguration()
                            let model = try Mushroom_Identification_Model(configuration: config)
                            
                            Task {
                                if let ciImage = CIImage(contentsOf: try await medias[0].getUrl()!) {
                                    let context = CIContext()
                                    var cvPixelBuffer: CVPixelBuffer?
                                    context.render(ciImage, to: (cvPixelBuffer)!)
                                    
                                    let prediction = try await model.prediction(image: cvPixelBuffer!)
                                    
                                    typeOfMushroom = prediction.classLabel
                                    
                                    
                                    if (prediction.classLabel == "Edible Mushroom") {
                                        fgc = .green
                                    } else {
                                        fgc = .red
                                    }
                                    print(prediction.classLabelProbs)
                                } else {
                                    print("Err with CI Image")
                                    typeOfMushroom = "Err occured with Image, try again!"
                                    fgc = .orange
                                }
                            }
                        } catch {
                            print(error.localizedDescription)
                            typeOfMushroom = error.localizedDescription
                            fgc = .orange
                        }
                    } else {
                        print("Media array is empty")
                        print(medias)
                    }
                } label: {
                    HStack {
                        Text("Identify Mushroom!")
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .tint(.accentColor)
                    }
                    .font(.title2)
                    .foregroundColor(Color(uiColor: .systemBlue))
                }
                
                Text(typeOfMushroom)
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(fgc)
            }
            .foregroundColor(Color(uiColor: .label))
            .navigationTitle("Wildshroom")
            
        }
        .sheet(isPresented: $showCustomizedMediaPicker) {
            CustomizedMediaPicker(isPresented: $showCustomizedMediaPicker, medias: $medias)
        }
    }
    
    
    
    struct MediaCell: View {
        
        var media: Media
        @State var url: URL?
        
        var body: some View {
            GeometryReader { g in
                if let url = url {
                    AsyncImage(
                        url: url,
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: g.size.width, height: g.size.width)
                                .clipped()
                        },
                        placeholder: {
                            ProgressView()
                        }
                    )
                }
            }
            .task {
                url = await media.getUrl()
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
