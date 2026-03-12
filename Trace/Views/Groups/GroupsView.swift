//
//  GroupsView.swift
//  Trace
//
//  Friend groups + Community with gamification
//

import SwiftUI
import SwiftData

struct GroupsView: View {
    @Query(sort: \WorkoutGroup.createdDate, order: .reverse) private var groups: [WorkoutGroup]
    @Query(sort: \Community.createdDate, order: .reverse) private var communities: [Community]
    @State private var selectedSegment = 0
    @State private var showCreateGroup = false
    @State private var showCreateCommunity = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segment Control
                Picker("", selection: $selectedSegment) {
                    Text("My Groups").tag(0)
                    Text("Communities").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                ScrollView {
                    if selectedSegment == 0 {
                        groupsContent
                    } else {
                        communitiesContent
                    }
                }
            }
            .background(Color.traceBackground)
            .navigationTitle("Groups")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if selectedSegment == 0 {
                            showCreateGroup = true
                        } else {
                            showCreateCommunity = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.traceAccent)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showCreateGroup) {
                CreateGroupSheet()
            }
            .sheet(isPresented: $showCreateCommunity) {
                CreateCommunitySheet()
            }
        }
    }
    
    // MARK: - Groups Content
    private var groupsContent: some View {
        VStack(spacing: 16) {
            if groups.isEmpty {
                emptyState(
                    icon: "person.3.fill",
                    title: "No Groups Yet",
                    subtitle: "Create a group to track workouts with friends"
                )
            } else {
                ForEach(groups) { group in
                    NavigationLink(destination: GroupDetailView(group: group)) {
                        GroupCard(group: group)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Communities Content
    private var communitiesContent: some View {
        VStack(spacing: 16) {
            if communities.isEmpty {
                emptyState(
                    icon: "globe",
                    title: "No Communities Yet",
                    subtitle: "Join or create a community for public events"
                )
            } else {
                ForEach(communities) { community in
                    NavigationLink(destination: CommunityDetailView(community: community)) {
                        CommunityCard(community: community)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private func emptyState(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundColor(.traceTextTertiary)
            Text(title)
                .font(.headline)
                .foregroundColor(.traceTextSecondary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.traceTextTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Group Card
struct GroupCard: View {
    let group: WorkoutGroup
    
    private var weeklyProgress: CGFloat {
        guard group.weeklyGoal > 0 else { return 0 }
        return min(CGFloat(group.weeklyPoints) / CGFloat(group.weeklyGoal), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.headline)
                        .foregroundColor(.traceTextPrimary)
                    Text("\(group.memberNames.count) members · \(group.minWorkoutsPerWeek)/wk min")
                        .font(.caption)
                        .foregroundColor(.traceTextSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(group.totalPoints)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.traceAccent)
                    Text("points")
                        .font(.caption2)
                        .foregroundColor(.traceTextSecondary)
                }
            }
            
            // Weekly progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Weekly Goal")
                        .font(.caption)
                        .foregroundColor(.traceTextSecondary)
                    Spacer()
                    Text("\(group.weeklyPoints)/\(group.weeklyGoal)")
                        .font(.caption)
                        .foregroundColor(.traceTextSecondary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.traceCardLight)
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.traceAccent)
                            .frame(width: geo.size.width * weeklyProgress, height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .cardStyle()
    }
}

// MARK: - Community Card
struct CommunityCard: View {
    let community: Community
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "globe")
                    .font(.title3)
                    .foregroundColor(.traceAccent)
                    .frame(width: 40, height: 40)
                    .background(Color.traceAccentDim)
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(community.name)
                        .font(.headline)
                        .foregroundColor(.traceTextPrimary)
                    Text("\(community.memberCount) members · \(community.events.count) events")
                        .font(.caption)
                        .foregroundColor(.traceTextSecondary)
                }
                Spacer()
                
                if community.isPublic {
                    Text("Public")
                        .font(.caption2)
                        .foregroundColor(.traceAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.traceAccentDim)
                        .cornerRadius(6)
                }
            }
            
            if !community.communityDescription.isEmpty {
                Text(community.communityDescription)
                    .font(.caption)
                    .foregroundColor(.traceTextSecondary)
                    .lineLimit(2)
            }
        }
        .cardStyle()
    }
}

// MARK: - Create Group Sheet
struct CreateGroupSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var minWorkouts = 3
    @State private var memberName = ""
    @State private var members: [String] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Group Info") {
                    TextField("Group Name", text: $name)
                    TextField("Description (optional)", text: $description)
                }
                
                Section("Weekly Minimum Workouts") {
                    Stepper("\(minWorkouts) workouts/week", value: $minWorkouts, in: 1...7)
                }
                
                Section("Members") {
                    HStack {
                        TextField("Add member name", text: $memberName)
                        Button("Add") {
                            if !memberName.isEmpty {
                                members.append(memberName)
                                memberName = ""
                            }
                        }
                        .foregroundColor(.traceAccent)
                    }
                    
                    ForEach(members, id: \.self) { member in
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.traceAccent)
                            Text(member)
                        }
                    }
                    .onDelete { members.remove(atOffsets: $0) }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.traceBackground)
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let group = WorkoutGroup(name: name, description: description, minWorkoutsPerWeek: minWorkouts)
                        group.memberNames = members
                        context.insert(group)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Create Community Sheet
struct CreateCommunitySheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var isPublic = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Community Info") {
                    TextField("Community Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                Section {
                    Toggle("Public Community", isOn: $isPublic)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.traceBackground)
            .navigationTitle("Create Community")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let community = Community(name: name, description: description, isPublic: isPublic)
                        context.insert(community)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Group Detail
struct GroupDetailView: View {
    @Bindable var group: WorkoutGroup
    @State private var showAddMember = false
    @State private var newMemberName = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Points Banner
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Points")
                            .font(.subheadline)
                            .foregroundColor(.traceTextSecondary)
                        Text("\(group.totalPoints)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.traceAccent)
                    }
                    Spacer()
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.traceAccent.opacity(0.3))
                }
                .cardStyle()
                
                // Members
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Members")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.traceTextPrimary)
                        Spacer()
                        Button {
                            showAddMember = true
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.traceAccent)
                        }
                    }
                    
                    ForEach(group.memberNames, id: \.self) { name in
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.traceAccent)
                            Text(name)
                                .font(.subheadline)
                                .foregroundColor(.traceTextPrimary)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .cardStyle()
                
                // Settings
                VStack(alignment: .leading, spacing: 8) {
                    Text("Settings")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.traceTextPrimary)
                    
                    HStack {
                        Text("Min workouts/week")
                            .foregroundColor(.traceTextSecondary)
                        Spacer()
                        Text("\(group.minWorkoutsPerWeek)")
                            .foregroundColor(.traceAccent)
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
                .cardStyle()
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .background(Color.traceBackground)
        .navigationTitle(group.name)
        .alert("Add Member", isPresented: $showAddMember) {
            TextField("Name", text: $newMemberName)
            Button("Add") {
                if !newMemberName.isEmpty {
                    group.memberNames.append(newMemberName)
                    newMemberName = ""
                }
            }
            Button("Cancel", role: .cancel) { newMemberName = "" }
        }
    }
}

// MARK: - Community Detail
struct CommunityDetailView: View {
    @Bindable var community: Community
    @State private var showCreateEvent = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    if !community.communityDescription.isEmpty {
                        Text(community.communityDescription)
                            .font(.subheadline)
                            .foregroundColor(.traceTextSecondary)
                    }
                    HStack {
                        Label("\(community.memberCount) members", systemImage: "person.2.fill")
                        Spacer()
                        Label(community.isPublic ? "Public" : "Private", systemImage: community.isPublic ? "globe" : "lock.fill")
                    }
                    .font(.caption)
                    .foregroundColor(.traceTextSecondary)
                }
                .cardStyle()
                
                // Events
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Events")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.traceTextPrimary)
                        Spacer()
                        Button {
                            showCreateEvent = true
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.traceAccent)
                        }
                    }
                    
                    if community.events.isEmpty {
                        Text("No events yet")
                            .font(.subheadline)
                            .foregroundColor(.traceTextTertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    } else {
                        ForEach(community.events) { event in
                            EventCard(event: event)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .background(Color.traceBackground)
        .navigationTitle(community.name)
        .sheet(isPresented: $showCreateEvent) {
            CreateEventSheet(community: community)
        }
    }
}

// MARK: - Event Card
struct EventCard: View {
    let event: CommunityEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.traceTextPrimary)
                Spacer()
                Text(event.isOnline ? "Online" : "In-Person")
                    .font(.caption2)
                    .foregroundColor(.traceAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.traceAccentDim)
                    .cornerRadius(6)
            }
            
            HStack {
                Image(systemName: "calendar")
                Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                Spacer()
                Image(systemName: "person.2")
                Text("\(event.participantCount)")
            }
            .font(.caption)
            .foregroundColor(.traceTextSecondary)
        }
        .cardStyle()
    }
}

// MARK: - Create Event Sheet
struct CreateEventSheet: View {
    let community: Community
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var isOnline = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event Info") {
                    TextField("Event Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                }
                
                Section("Schedule") {
                    DatePicker("Start", selection: $startDate)
                    DatePicker("End", selection: $endDate)
                }
                
                Section {
                    Toggle("Online Event", isOn: $isOnline)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.traceBackground)
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let event = CommunityEvent(
                            name: name,
                            description: description,
                            startDate: startDate,
                            endDate: endDate,
                            isOnline: isOnline
                        )
                        event.community = community
                        community.events.append(event)
                        context.insert(event)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
