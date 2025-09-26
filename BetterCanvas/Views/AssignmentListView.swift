import SwiftUI

/// View for displaying a list of assignments
struct AssignmentListView: View {
    @StateObject private var viewModel = AssignmentListViewModel()
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter and Sort Controls
                if !viewModel.assignments.isEmpty {
                    filterControls
                }
                
                // Assignment List
                assignmentList
            }
            .navigationTitle(viewModel.showAllAssignments ? "All Assignments" : "Assignments")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilters.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if !viewModel.showAllAssignments {
                        Button("All Courses") {
                            viewModel.loadAllAssignments()
                        }
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingFilters.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    if !viewModel.showAllAssignments {
                        Button("All Courses") {
                            viewModel.loadAllAssignments()
                        }
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingFilters) {
                FilterSheet(viewModel: viewModel)
            }
            .task {
                await viewModel.loadAssignments()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
    
    // MARK: - Filter Controls
    
    private var filterControls: some View {
        VStack(spacing: 8) {
            // Sort and Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Sort Options
                    ForEach(AssignmentSortOption.allCases, id: \.self) { option in
                        FilterPill(
                            title: option.displayName,
                            isSelected: viewModel.sortOption == option,
                            action: {
                                viewModel.setSortOption(option)
                            }
                        )
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    // Filter Options
                    ForEach(AssignmentFilterOption.allCases, id: \.self) { option in
                        FilterPill(
                            title: option.displayName,
                            isSelected: viewModel.filterOption == option,
                            action: {
                                viewModel.setFilterOption(option)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color.systemBackground)
    }
    
    // MARK: - Assignment List
    
    private var assignmentList: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(errorMessage)
            } else if viewModel.assignments.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.assignments) { assignment in
                        AssignmentRowView(assignment: assignment)
                            .environmentObject(viewModel)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading assignments...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Error Loading Assignments")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                Task {
                    await viewModel.refresh()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Assignments Found")
                .font(.headline)
            
            Text("No assignments match your current filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Clear Filters") {
                viewModel.setFilterOption(.all)
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Assignment Row View

struct AssignmentRowView: View {
    let assignment: Assignment
    @EnvironmentObject var viewModel: AssignmentListViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Assignment Title and Status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(assignment.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    let courseName = viewModel.getCourseName(for: assignment)
                    Text(courseName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Badge
                statusBadge
            }
            
            // Due Date and Points
            HStack {
                if let dueDate = assignment.formattedDueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(dueDate)
                            .font(.caption)
                    }
                    .foregroundColor(dueDateColor)
                }
                
                Spacer()
                
                if let points = assignment.pointsPossible {
                    Text("\(Int(points)) pts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Submission Types
            if let submissionTypes = assignment.submissionTypes, !submissionTypes.isEmpty {
                HStack(spacing: 8) {
                    ForEach(submissionTypes.prefix(3), id: \.self) { type in
                        SubmissionTypeBadge(type: type)
                    }
                    
                    if submissionTypes.count > 3 {
                        Text("+\(submissionTypes.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Status Badge
    
    private var statusBadge: some View {
        Text(assignment.submissionStatus.displayText)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusBadgeColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    private var statusBadgeColor: Color {
        switch assignment.submissionStatus {
        case .submitted:
            return .green
        case .late:
            return .orange
        case .overdue:
            return .red
        case .notSubmitted:
            return .gray
        }
    }
    
    private var dueDateColor: Color {
        if assignment.isOverdue {
            return .red
        } else if assignment.isDueSoon {
            return .orange
        } else {
            return .secondary
        }
    }
    
}

// MARK: - Submission Type Badge

struct SubmissionTypeBadge: View {
    let type: String
    
    var body: some View {
        Text(displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(4)
    }
    
    private var displayName: String {
        switch type {
        case "online_upload":
            return "File"
        case "online_text_entry":
            return "Text"
        case "online_url":
            return "URL"
        case "on_paper":
            return "Paper"
        case "external_tool":
            return "Tool"
        default:
            return type.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}

// MARK: - Filter Pill

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color.systemGray6)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @ObservedObject var viewModel: AssignmentListViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Sort Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sort By")
                        .font(.headline)
                    
                    ForEach(AssignmentSortOption.allCases, id: \.self) { option in
                        HStack {
                            Text(option.displayName)
                            Spacer()
                            if viewModel.sortOption == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.setSortOption(option)
                        }
                    }
                }
                
                Divider()
                
                // Filter Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Filter By")
                        .font(.headline)
                    
                    ForEach(AssignmentFilterOption.allCases, id: \.self) { option in
                        HStack {
                            Text(option.displayName)
                            Spacer()
                            if viewModel.filterOption == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.setFilterOption(option)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Filters")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
}

// MARK: - Preview

struct AssignmentListView_Previews: PreviewProvider {
    static var previews: some View {
        AssignmentListView()
    }
}
