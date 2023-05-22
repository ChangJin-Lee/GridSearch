//
//  ContentView.swift
//  GridSearchBTA
//
//  Created by CHANG JIN LEE on 2023/03/12.
//

import SwiftUI
import Foundation

struct RSS: Decodable {
    let feed: Feed
}

struct Feed: Decodable {
    let results: [Result]
}

struct Result: Decodable, Hashable {
    let name, artworkUrl100, releaseDate: String
    
    let copyright: String?
}

class GridViewModel: ObservableObject {
    
    @Published var items = 0..<5
    
    @Published var results = [Result]()
    
    init(){
        // json decofing simulation
//        Timer.scheduledTimer(withTimeInterval: 2, repeats: false){ (_) in
//            self.items = 0..<15
        
        // search "ios json rss" in google
            guard let url = URL(string:
            "https://rss.applemarketingtools.com/api/v2/kr/apps/top-free/50/apps.json"
            ) else{ return }
            URLSession.shared.dataTask(with: url) { (data, resp, err) in
                // check response status and aerr
                guard let data = data else {return}
                do{
                    let rss = try JSONDecoder().decode(RSS.self, from: data)
                    print(rss)
                    self.results = rss.feed.results
                } catch{
                    print("Failed to decode: \(error)")
                }
            }.resume()
    }
}

import Kingfisher

struct ContentView: View {
    
    @ObservedObject var vm = GridViewModel()
    
    var body: some View {
        NavigationView{
            ScrollView{
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16, alignment: .top),
                    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16, alignment: .top),
                    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16)
                ], alignment: .leading, spacing: 16, content: {
                    ForEach(vm.results, id: \.self){ app in
                        AppInfo(app: app)
//                        .padding(.horizontal)
//                        .background(Color.red)
                        
                    }
                    
                    
                })
            }.navigationTitle("grid search LBTA")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AppInfo: View {
    
    let app: Result
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            
            KFImage(URL(string: app.artworkUrl100))
                .resizable()
                .scaledToFill()
                .cornerRadius(24)
            
            //                            Spacer()
            //                                .frame(width:100, height: 100)
            //                                .background(Color.blue)
            
            Text(app.name)
                .font(.system(size: 10, weight:  .semibold))
                .padding(.top,4)
            Text(app.releaseDate)
                .font(.system(size: 9, weight:  .regular))
            
            Text("Copyright © 2023 Apple Inc. All rights reserved.")
                .font(.system(size: 9, weight:  .regular))
                .foregroundColor(.gray)
            if let copyright = app.copyright{
                Text(copyright)
                    .font(.system(size: 9, weight:  .regular))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}
