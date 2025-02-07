//
//  MainListView.swift
//  TheDogApp
//
//  Created by Joseluis SN on 7/02/25.
//
import SwiftUI

struct MainListView: View {
    @StateObject var viewModel: DogViewModel
    @State private var searchText = ""
    
    var filteredDogs: [Dog] {
        if searchText.isEmpty {
            return viewModel.dogs
        } else {
            return viewModel.dogs.filter { dog in
                dog.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("🐶 Dog Breeds")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search dog breeds...", text: $searchText)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                ScrollView {
                    LazyVStack {
                        ForEach(filteredDogs.indices, id: \.self) { index in
                            let dog = filteredDogs[index]
                            
                            NavigationLink(destination: DetailListView(dog: dog)) {
                                HStack {
                                    Text(dog.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                                )
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                if index == viewModel.dogs.count - 1 { 
                                    viewModel.fetchDogs()
                                }
                            }
                            Spacer(minLength: 15)
                        }
                    }
                }.padding(.top, 10)

            }
            .navigationBarHidden(true)
            .onAppear {
                if viewModel.dogs.isEmpty {
                    viewModel.fetchDogs()
                }
            }
        }
    }
}
