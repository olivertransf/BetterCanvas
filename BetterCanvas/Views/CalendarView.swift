import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showingAssignmentDetail = false
    @State private var selectedAssignment: Assignment?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Month Navigation Header
                monthNavigationHeader
                
                // Calendar Grid
                calendarGrid
                
                // Selected Date Assignments
                selectedDateAssignments
            }
            .navigationTitle("Calendar")
            .task {
                await viewModel.loadAssignments()
            }
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $showingAssignmentDetail) {
                if let assignment = selectedAssignment {
                    AssignmentDetailView(assignment: assignment)
                }
            }
        }
    }
    
    // MARK: - Month Navigation Header
    
    private var monthNavigationHeader: some View {
        HStack {
            Button(action: {
                viewModel.previousMonth()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            
            Spacer()
            
            Text(viewModel.currentMonth, style: .date)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                viewModel.nextMonth()
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.systemBackground)
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        VStack(spacing: 0) {
            // Day headers
            HStack(spacing: 0) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
            .background(Color.systemGray6)
            
            // Calendar days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 1) {
                ForEach(calendarDays, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                        isCurrentMonth: Calendar.current.isDate(date, equalTo: viewModel.currentMonth, toGranularity: .month),
                        assignmentCount: viewModel.assignmentCount(for: date),
                        hasAssignments: viewModel.hasAssignments(for: date)
                    ) {
                        viewModel.selectedDate = date
                    }
                }
            }
            .background(Color.systemGray6)
        }
        .background(Color.systemBackground)
    }
    
    // MARK: - Selected Date Assignments
    
    private var selectedDateAssignments: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Assignments for \(viewModel.selectedDate, style: .date)")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                Spacer()
            }
            
            if viewModel.isLoading {
                ProgressView("Loading assignments...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Error")
                        .font(.headline)
                    
                    Text(errorMessage)
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
                .padding()
            } else {
                let dayAssignments = viewModel.getAssignments(for: viewModel.selectedDate)
                
                if dayAssignments.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No assignments")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("No assignments due on this day")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(dayAssignments) { assignment in
                                CalendarAssignmentRowView(assignment: assignment, viewModel: viewModel)
                                    .onTapGesture {
                                        selectedAssignment = assignment
                                        showingAssignmentDetail = true
                                    }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .background(Color.systemBackground)
    }
    
    // MARK: - Computed Properties
    
    private var calendarDays: [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: viewModel.currentMonth)?.start ?? viewModel.currentMonth
        let _ = calendar.dateInterval(of: .month, for: viewModel.currentMonth)?.end ?? viewModel.currentMonth
        
        // Get the first day of the week for the start of the month
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysToSubtract = firstWeekday - 1 // Sunday = 1, so subtract 1 to get days to go back
        
        let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: startOfMonth) ?? startOfMonth
        
        var days: [Date] = []
        var currentDate = startDate
        
        // Generate 42 days (6 weeks) to fill the calendar grid
        for _ in 0..<42 {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
}

// MARK: - Calendar Day View

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let assignmentCount: Int
    let hasAssignments: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                    .foregroundColor(textColor)
                
                if hasAssignments {
                    HStack(spacing: 2) {
                        ForEach(0..<min(assignmentCount, 3), id: \.self) { _ in
                            Circle()
                                .fill(assignmentColor)
                                .frame(width: 4, height: 4)
                        }
                        
                        if assignmentCount > 3 {
                            Text("+")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(assignmentColor)
                        }
                    }
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .accentColor
        } else if hasAssignments {
            return Color.accentColor.opacity(0.1)
        } else {
            return .clear
        }
    }
    
    private var assignmentColor: Color {
        if isSelected {
            return .white
        } else {
            return .accentColor
        }
    }
}

// MARK: - Assignment Detail View

struct AssignmentDetailView: View {
    let assignment: Assignment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Assignment Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(assignment.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let dueAt = assignment.dueAt {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.accentColor)
                                Text("Due: \(dueAt, style: .date) at \(dueAt, style: .time)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let points = assignment.pointsPossible {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.accentColor)
                                Text("\(points, specifier: "%.0f") points")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.systemGray6)
                    .cornerRadius(12)
                    
                    // Description
                    if let description = assignment.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                            
                            Text(description)
                                .font(.body)
                        }
                        .padding()
                        .background(Color.systemGray6)
                        .cornerRadius(12)
                    }
                    
                    // Submission Types
                    if let submissionTypes = assignment.submissionTypes, !submissionTypes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Submission Types")
                                .font(.headline)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                ForEach(submissionTypes, id: \.self) { type in
                                    Text(type.replacingOccurrences(of: "_", with: " ").capitalized)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.accentColor.opacity(0.2))
                                        .cornerRadius(6)
                                }
                            }
                        }
                        .padding()
                        .background(Color.systemGray6)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Assignment Details")
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


// MARK: - Calendar Assignment Row View

struct CalendarAssignmentRowView: View {
    let assignment: Assignment
    let viewModel: CalendarViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Assignment Title and Status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(assignment.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    if let dueAt = assignment.dueAt {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.accentColor)
                            Text(dueAt, style: .time)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let points = assignment.pointsPossible {
                        Text("\(points, specifier: "%.0f") pts")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    // Status indicator
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                }
            }
            
            // Course name
            Text(viewModel.getCourseName(for: assignment))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.systemGray6)
        .cornerRadius(12)
    }
    
    private var statusColor: Color {
        if assignment.isOverdue {
            return .red
        } else if assignment.isDueSoon {
            return .orange
        } else {
            return .green
        }
    }
}

// MARK: - Preview

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
