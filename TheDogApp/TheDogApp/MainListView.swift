//
//  MainListView.swift
//  TheDogApp
//
//  Created by Joseluis SN on 7/02/25.
//

import SwiftUI
import LocalAuthentication
import FirebaseAuth

struct MainListView: View {
    @StateObject var viewModel: DogViewModel
    @State private var searchText = ""
    @EnvironmentObject var router: Router
    @Environment(\.presentationMode) var presentationMode
    @State private var isBiometricEnabled: Bool = false
    
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
                topSheet
                searchBar
                list
            }
            .onAppear {
                if viewModel.dogs.isEmpty {
                    viewModel.fetchDogs()
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var topSheet: some View {
        HStack {
            Image(systemName: "gearshape").foregroundStyle(Color.black)
                .font(.system(size: 30))
                .onTapGesture {
                router.navigate(to: .settingsView)
                }
            
            Text("🐶 Dog Breeds")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
                .accessibilityIdentifier("dogBreedsTitle")
                .foregroundStyle(Color.black)
        }
        .padding(.horizontal, 16)
        
    }
    
    private var searchBar: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search dog breeds...", text: $searchText)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .accessibilityIdentifier("dogSearchField")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }
    
    private var list: some View {
            ScrollView {
                LazyVStack {
                    ForEach(filteredDogs.indices, id: \.self) { index in
                        let dog = filteredDogs[index]
                        
                        NavigationLink(destination: DetailView(dog: dog)) {
                            HStack {
                                Text(dog.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .accessibilityIdentifier("dogName_\(dog.name)")
                                Spacer()
                                if let imageURL = dog.image?.url {
                                    AsyncImage(url: URL(string: imageURL)) { image in
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 120)
                                    } placeholder: {
                                        ProgressView()
                                            .accessibilityIdentifier("dogImagePlaceholder_\(dog.name)")
                                    }
                                }
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
                        .accessibilityIdentifier("dogRow_\(index)")
                        .onAppear {
                            if index == viewModel.dogs.count - 1 {
                                viewModel.fetchDogs()
                            }
                        }
                        Spacer(minLength: 10)
                    }
                }
            }
            .padding(.top, 10)
    }
}

#Preview {
    MainListView(viewModel: DogViewModel())
}

