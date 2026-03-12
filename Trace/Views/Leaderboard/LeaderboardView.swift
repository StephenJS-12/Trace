//
//  LeaderboardView.swift
//  Trace
//
//  Public leaderboards - individual and group, filterable by region
//

import SwiftUI
import SwiftData

struct LeaderboardView: View {
    @Query(sort: \LeaderboardEntry.points, order: .reverse) private var entries: [LeaderboardEntry]
    @Query private var profiles: [UserProfile]
    @State private var selectedTab = 0 // 0 = Individual, 1 = Groups
    @State private var selectedRegion = "Global"
    
    private let regions = ["Global", "Continent", "Country", "Province", "City"]
    
    private var profile: UserProfile? { profiles.first }
    
    private var filteredEntries: [LeaderboardEntry] {
        let filtered = entries.filter { $0.isGroup == (selectedTab == 1) }
        return filtered.enumerated().map { index, entry in
            entry.rank = index + 1
            return entry
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("", selection: $selectedTab) {
                    Text("Individual").tag(0)
                    Text("Groups").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Region Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(regions, id: \.self) { region in
                            Button {
                                selectedRegion = region
                            } label: {
                                Text(region)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedRegion == region ? .black : .traceTextSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedRegion == region ? Color.traceAccent : Color.traceCard)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                
                // Top 3 Podium
                if filteredEntries.count >= 3 {
                    podiumView
                }
                
                // Your Rank
                if let profile = profile {
                    yourRankCard(profile: profile)
                }
                
                // Full List
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(filteredEntries) { entry in
                            LeaderboardRow(entry: entry)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .background(Color.traceBackground)
            .navigationTitle("Leaderboard")
        }
    }
    
    // MARK: - Podium
    private var podiumView: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // 2nd Place
            podiumItem(entry: filteredEntries[1], height: 80, medal: "2")
            
            // 1st Place
            podiumItem(entry: filteredEntries[0], height: 100, medal: "1")
            
            // 3rd Place
            podiumItem(entry: filteredEntries[2], height: 65, medal: "3")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    private func podiumItem(entry: LeaderboardEntry, height: CGFloat, medal: String) -> some View {
        VStack(spacing: 8) {
            // Avatar
            ZStack {
                Circle()
                    .fill(medal == "1" ? Color.traceAccent : Color.traceCard)
                    .frame(width: medal == "1" ? 56 : 44, height: medal == "1" ? 56 : 44)
                Text(String(entry.playerName.prefix(1)))
                    .font(medal == "1" ? .title2 : .body)
                    .fontWeight(.bold)
                    .foregroundColor(medal == "1" ? .black : .traceTextPrimary)
            }
            
            Text(entry.playerName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.traceTextPrimary)
                .lineLimit(1)
            
            Text("\(entry.points) pt")
                .font(.caption2)
                .foregroundColor(.traceAccent)
            
            // Podium bar
            RoundedRectangle(cornerRadius: 8)
                .fill(medal == "1" ? Color.traceAccent.opacity(0.3) : Color.traceCard)
                .frame(height: height)
                .overlay(
                    Text(medal)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(medal == "1" ? .traceAccent : .traceTextSecondary)
                )
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Your Rank
    private func yourRankCard(profile: UserProfile) -> some View {
        HStack(spacing: 14) {
            Text("You")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.traceTextPrimary)
            Spacer()
            Text("\(profile.totalPoints) pts")
                .font(.subheadline)
                .foregroundColor(.traceAccent)
                .fontWeight(.semibold)
            Image(systemName: "chevron.up")
                .font(.caption)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color.traceAccent.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack(spacing: 14) {
            Text("\(entry.rank)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.traceTextSecondary)
                .frame(width: 28)
            
            Circle()
                .fill(Color.traceCardLight)
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(entry.playerName.prefix(1)))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.traceTextPrimary)
                )
            
            Text(entry.playerName)
                .font(.subheadline)
                .foregroundColor(.traceTextPrimary)
            
            Spacer()
            
            Text("\(entry.points) pts")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.traceTextSecondary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
    }
}
