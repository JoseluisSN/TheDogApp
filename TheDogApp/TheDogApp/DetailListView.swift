//
//  DetailListView.swift
//  TheDogApp
//
//  Created by Joseluis SN on 7/02/25.
//
import SwiftUI

struct DetailListView: View {
    let dog: Dog
    @StateObject private var viewModel = DogDetailViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let detail = viewModel.dogDetail {
                VStack(alignment: .leading, spacing: 16) {
                    Text(detail.name)
                        .font(.largeTitle)
                        .bold()

                    CharacteristicCard(title: "Origin", value: detail.origin ?? "Unknown", icon: "globe")
                    CharacteristicCard(title: "Bred For", value: detail.bredFor ?? "Unknown", icon: "pawprint.fill")
                    CharacteristicCard(title: "Breed Group", value: detail.breedGroup ?? "Unknown", icon: "person.3.fill")
                    CharacteristicCard(title: "Life Span", value: detail.lifeSpan, icon: "clock")
                    CharacteristicCard(title: "Weight", value: "\(detail.weight.metric) kg (\(detail.weight.imperial) lbs)", icon: "scalemass.fill")
                    CharacteristicCard(title: "Height", value: "\(detail.height.metric) cm (\(detail.height.imperial) in)", icon: "ruler.fill")

                    if let temperament = detail.temperament {
                        CharacteristicCard(title: "Temperament", value: temperament, icon: "face.smiling.fill")
                    }
                }
                .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.body)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            viewModel.fetchDogDetail(for: dog.id)
        }
    }
}



struct CharacteristicCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.black)
                .padding(.horizontal, 5)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}
