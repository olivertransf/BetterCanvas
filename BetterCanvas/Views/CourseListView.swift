import SwiftUI

struct CourseListView: View {
  @StateObject private var viewModel = CourseListViewModel()

  var body: some View {
    NavigationView {
      VStack {
        if viewModel.isLoading && viewModel.courses.isEmpty {
          loadingView
        } else if viewModel.courses.isEmpty && !viewModel.isLoading {
          emptyStateView
        } else {
          courseListContent
        }
      }
      .navigationTitle("Courses")
      .searchable(text: $viewModel.searchText, prompt: "Search courses...")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          HStack {
            Button(action: {
              viewModel.toggleStarredFilter()
            }) {
              Image(systemName: viewModel.showOnlyStarred ? "star.fill" : "star")
            }
            .foregroundColor(viewModel.showOnlyStarred ? .yellow : .primary)
            
            Button(action: {
              Task {
                await viewModel.refreshCourses()
              }
            }) {
              Image(systemName: "arrow.clockwise")
            }
            .disabled(viewModel.isRefreshing)
          }
        }
      }
      .refreshable {
        await viewModel.refreshCourses()
      }
      .alert("Error", isPresented: .constant(viewModel.hasError)) {
        Button("OK") {
          viewModel.clearError()
        }
      } message: {
        Text(viewModel.errorMessage ?? "")
      }
    }
  }

  // MARK: - View Components

  private var loadingView: some View {
    VStack(spacing: 20) {
      ProgressView()
        .scaleEffect(1.5)

      Text("Loading courses...")
        .font(.headline)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "book.closed")
        .font(.system(size: 60))
        .foregroundColor(.gray)

      Text("No Courses Loaded")
        .font(.title2)
        .fontWeight(.semibold)

      Text("Tap 'Fetch All Courses' to load your courses from Canvas.")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)

      Button(action: {
        Task {
          await viewModel.refreshCourses()
        }
      }) {
        HStack {
          Image(systemName: "arrow.clockwise")
          Text("Fetch All Courses")
        }
      }
      .buttonStyle(.borderedProminent)
      .disabled(viewModel.isRefreshing)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var courseListContent: some View {
    VStack(spacing: 0) {
      // Header with filter status and refresh button
      HStack {
        if viewModel.showOnlyStarred {
          HStack(spacing: 4) {
            Image(systemName: "star.fill")
              .foregroundColor(.yellow)
            Text("Showing \(FavoritesManager.shared.getFavoriteCount()) starred courses")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        } else if !viewModel.courses.isEmpty {
          Text("Showing all courses")
            .font(.caption)
            .foregroundColor(.secondary)
        } else {
          Text("No courses loaded - tap refresh to fetch")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
        Spacer()
        
        Button(action: {
          Task {
            await viewModel.refreshCourses()
          }
        }) {
          HStack(spacing: 4) {
            Image(systemName: "arrow.clockwise")
            Text("Refresh All Courses")
          }
          .font(.caption)
        }
        .buttonStyle(.bordered)
        .disabled(viewModel.isRefreshing)
      }
      .padding(.horizontal)
      .padding(.vertical, 8)
      
      List {
        ForEach(viewModel.filteredCourses) { course in
          NavigationLink(destination: CourseDetailView(course: course)) {
            CourseRowView(course: course, viewModel: viewModel)
          }
        }
      }
      .listStyle(PlainListStyle())
    }
    .overlay(
      Group {
        if viewModel.isRefreshing {
          VStack {
            ProgressView()
              .scaleEffect(0.8)
            Text("Fetching all courses...")
              .font(.caption)
              .foregroundColor(.secondary)
          }
          .padding()
          .background(Color.white)
          .cornerRadius(8)
          .shadow(radius: 2)
        }
      }
    )
  }

}

// MARK: - Supporting Views

struct CourseRowView: View {
  let course: Course
  let viewModel: CourseListViewModel
  @ObservedObject private var favoritesManager = FavoritesManager.shared

  var body: some View {
    HStack {
      // Course Icon
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.accentColor.opacity(0.1))
        .frame(width: 50, height: 50)
        .overlay(
          Text(String((course.courseCode ?? "CO").prefix(2)).uppercased())
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.accentColor)
        )

      VStack(alignment: .leading, spacing: 4) {
        Text(course.displayName)
          .font(.headline)
          .lineLimit(2)

        if let courseCode = course.courseCode, !courseCode.isEmpty {
          Text(courseCode)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }

        HStack {
          StatusBadge(isActive: course.isActive)

          Button(action: {
            favoritesManager.toggleFavorite(courseId: course.id)
          }) {
            Image(systemName: favoritesManager.isFavorite(courseId: course.id) ? "star.fill" : "star")
              .font(.caption)
              .foregroundColor(favoritesManager.isFavorite(courseId: course.id) ? .yellow : .gray)
          }
          .buttonStyle(PlainButtonStyle())

          if let role = course.userRole {
            Text(role.replacingOccurrences(of: "Enrollment", with: ""))
              .font(.caption)
              .padding(.horizontal, 8)
              .padding(.vertical, 2)
              .background(Color.gray.opacity(0.2))
              .cornerRadius(4)
          }

          Spacer()
        }
      }

      Spacer()

      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding(.vertical, 4)
  }
}

struct StatusBadge: View {
  let isActive: Bool

  var body: some View {
    HStack(spacing: 4) {
      Circle()
        .fill(isActive ? Color.green : Color.gray)
        .frame(width: 6, height: 6)

      Text(isActive ? "Active" : "Completed")
        .font(.caption)
        .foregroundColor(isActive ? .green : .gray)
    }
  }
}


// MARK: - Course Detail View

struct CourseDetailView: View {
  let course: Course
  @StateObject private var viewModel = CourseDetailViewModel()
  @State private var selectedTab: CourseDetailTab = .overview
  
  var body: some View {
    VStack(spacing: 0) {
      // Course Header
      courseHeader
      
      // Tab Selector
      tabSelector
      
      // Content
      TabView(selection: $selectedTab) {
        OverviewTab(course: course, viewModel: viewModel)
          .tag(CourseDetailTab.overview)
        
        CourseAssignmentsTab(course: course, viewModel: viewModel)
          .tag(CourseDetailTab.assignments)
        
        GradesTab(course: course, viewModel: viewModel)
          .tag(CourseDetailTab.grades)
        
        DiscussionsTab(course: course, viewModel: viewModel)
          .tag(CourseDetailTab.discussions)
      }
      #if os(iOS)
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
      #endif
    }
    .navigationTitle(course.courseCode ?? course.name ?? "Unnamed Course")
    .task {
      await viewModel.loadCourseData(courseId: course.id)
    }
  }
  
  private var courseHeader: some View {
    VStack(spacing: 12) {
      // Course Icon and Basic Info
      HStack(spacing: 16) {
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.accentColor.opacity(0.1))
          .frame(width: 60, height: 60)
          .overlay(
            Text(String((course.courseCode ?? "CO").prefix(2)).uppercased())
              .font(.title2)
              .fontWeight(.bold)
              .foregroundColor(.accentColor)
          )
        
        VStack(alignment: .leading, spacing: 4) {
          Text(course.name ?? "Unnamed Course")
            .font(.title2)
            .fontWeight(.semibold)
            .lineLimit(2)
          
          if let courseCode = course.courseCode {
            Text(courseCode)
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
          
          HStack {
            StatusBadge(isActive: course.isActive)
            Spacer()
          }
        }
        
        Spacer()
      }
      
      // Course Stats
      if viewModel.isLoading {
        ProgressView("Loading course data...")
          .frame(maxWidth: .infinity)
      } else {
        HStack(spacing: 20) {
          StatItem(
            title: "Assignments",
            value: "\(viewModel.assignments.count)",
            icon: "doc.text.fill"
          )
          
          StatItem(
            title: "Discussions",
            value: "\(viewModel.discussions.count)",
            icon: "bubble.left.and.bubble.right.fill"
          )
          
          StatItem(
            title: "Grades",
            value: "\(viewModel.grades.count)",
            icon: "chart.bar.fill"
          )
        }
      }
    }
    .padding()
    .background(Color.systemBackground)
  }
  
  private var tabSelector: some View {
    HStack(spacing: 0) {
      ForEach(CourseDetailTab.allCases, id: \.self) { tab in
        Button(action: {
          selectedTab = tab
        }) {
          VStack(spacing: 4) {
            Image(systemName: tab.icon)
              .font(.system(size: 16))
            Text(tab.title)
              .font(.caption)
              .fontWeight(.medium)
          }
          .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
      }
    }
    .background(Color.systemGray6)
    .overlay(
      Rectangle()
        .frame(height: 1)
        .foregroundColor(Color.separator),
      alignment: .bottom
    )
  }
}

// MARK: - Course Detail Tabs

enum CourseDetailTab: String, CaseIterable {
  case overview = "Overview"
  case assignments = "Assignments"
  case grades = "Grades"
  case discussions = "Discussions"
  
  var title: String {
    return self.rawValue
  }
  
  var icon: String {
    switch self {
    case .overview:
      return "info.circle"
    case .assignments:
      return "doc.text"
    case .grades:
      return "chart.bar"
    case .discussions:
      return "bubble.left.and.bubble.right"
    }
  }
}

// MARK: - Supporting Views

struct StatItem: View {
  let title: String
  let value: String
  let icon: String
  
  var body: some View {
    VStack(spacing: 4) {
      Image(systemName: icon)
        .font(.title3)
        .foregroundColor(.accentColor)
      
      Text(value)
        .font(.headline)
        .fontWeight(.semibold)
      
      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity)
  }
}

// MARK: - Course Detail Tab Views

struct OverviewTab: View {
  let course: Course
  @ObservedObject var viewModel: CourseDetailViewModel
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        // Course Information
        VStack(alignment: .leading, spacing: 12) {
          Text("Course Information")
            .font(.headline)
            .fontWeight(.semibold)
          
          InfoRow(label: "Course Code", value: course.courseCode ?? "Not available")
          InfoRow(label: "Status", value: course.isActive ? "Active" : "Completed")
          
          if let startAt = course.startAt {
            InfoRow(label: "Start Date", value: startAt, style: .date)
          }
          
          if let endAt = course.endAt {
            InfoRow(label: "End Date", value: endAt, style: .date)
          }
        }
        .padding()
        .background(Color.systemGray6)
        .cornerRadius(12)
        
        // Grade Summary
        if !viewModel.grades.isEmpty {
          VStack(alignment: .leading, spacing: 12) {
            Text("Grade Summary")
              .font(.headline)
              .fontWeight(.semibold)
            
            HStack {
              VStack(alignment: .leading, spacing: 4) {
                Text("Average Grade")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                Text(viewModel.formattedAverageGrade)
                  .font(.title2)
                  .fontWeight(.bold)
                  .foregroundColor(.accentColor)
              }
              
              Spacer()
              
              VStack(alignment: .trailing, spacing: 4) {
                Text("Total Assignments")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                Text("\(viewModel.grades.count)")
                  .font(.title2)
                  .fontWeight(.bold)
              }
            }
          }
          .padding()
          .background(Color.systemGray6)
          .cornerRadius(12)
        }
        
        // Quick Stats
        VStack(alignment: .leading, spacing: 12) {
          Text("Quick Stats")
            .font(.headline)
            .fontWeight(.semibold)
          
          LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            QuickStatCard(
              title: "Assignments",
              value: "\(viewModel.assignments.count)",
              icon: "doc.text.fill",
              color: .blue
            )
            
            QuickStatCard(
              title: "Discussions",
              value: "\(viewModel.discussions.count)",
              icon: "bubble.left.and.bubble.right.fill",
              color: .green
            )
            
            QuickStatCard(
              title: "Graded",
              value: "\(viewModel.grades.filter { $0.score != nil }.count)",
              icon: "checkmark.circle.fill",
              color: .orange
            )
            
            QuickStatCard(
              title: "Pending",
              value: "\(viewModel.grades.filter { $0.score == nil }.count)",
              icon: "clock.fill",
              color: .red
            )
          }
        }
        .padding()
        .background(Color.systemGray6)
        .cornerRadius(12)
      }
      .padding()
    }
  }
}

struct CourseAssignmentsTab: View {
  let course: Course
  @ObservedObject var viewModel: CourseDetailViewModel
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 8) {
        ForEach(viewModel.sortedAssignments) { assignment in
          AssignmentRowView(assignment: assignment)
            .environmentObject(AssignmentListViewModel())
        }
      }
      .padding()
    }
  }
}

struct GradesTab: View {
  let course: Course
  @ObservedObject var viewModel: CourseDetailViewModel
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 8) {
        ForEach(viewModel.sortedGrades) { grade in
          GradeRowView(grade: grade)
        }
      }
      .padding()
    }
  }
}

struct DiscussionsTab: View {
  let course: Course
  @ObservedObject var viewModel: CourseDetailViewModel
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 8) {
        ForEach(viewModel.sortedDiscussions) { discussion in
          DiscussionRowView(discussion: discussion)
        }
      }
      .padding()
    }
  }
}

// MARK: - Supporting Detail Views

struct InfoRow: View {
  let label: String
  let value: Any
  let dateStyle: Text.DateStyle?
  
  init(label: String, value: String) {
    self.label = label
    self.value = value
    self.dateStyle = nil
  }
  
  init(label: String, value: Date, style: Text.DateStyle) {
    self.label = label
    self.value = value
    self.dateStyle = style
  }
  
  var body: some View {
    HStack {
      Text(label)
        .font(.subheadline)
        .foregroundColor(.secondary)
        .frame(width: 100, alignment: .leading)
      
      if let date = value as? Date, let dateStyle = dateStyle {
        Text(date, style: dateStyle)
          .font(.subheadline)
      } else {
        Text(String(describing: value))
          .font(.subheadline)
      }
      
      Spacer()
    }
  }
}

struct QuickStatCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color
  
  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundColor(color)
      
      Text(value)
        .font(.headline)
        .fontWeight(.bold)
      
      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color.systemBackground)
    .cornerRadius(8)
  }
}

struct GradeRowView: View {
  let grade: Grade
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(grade.assignmentName)
          .font(.headline)
          .lineLimit(2)
        
        Text(grade.courseName)
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 4) {
        Text(grade.formattedScore)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(gradeColor)
        
        if let percentage = grade.formattedPercentage {
          Text(percentage)
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
    .padding()
    .background(Color.systemGray6)
    .cornerRadius(12)
  }
  
  private var gradeColor: Color {
    if grade.excused {
      return .blue
    } else if grade.missing {
      return .red
    } else if grade.late {
      return .orange
    } else if grade.score != nil {
      return .green
    } else {
      return .secondary
    }
  }
}

struct DiscussionRowView: View {
  let discussion: Discussion
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(discussion.title)
            .font(.headline)
            .lineLimit(2)
          
          if let message = discussion.message, !message.isEmpty {
            Text(message)
              .font(.subheadline)
              .foregroundColor(.secondary)
              .lineLimit(3)
          }
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 4) {
          if let unreadCount = discussion.unreadCount, unreadCount > 0 {
            Text("\(unreadCount)")
              .font(.caption)
              .fontWeight(.bold)
              .foregroundColor(.white)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(Color.red)
              .cornerRadius(8)
          }
          
          if let lastReplyAt = discussion.lastReplyAt {
            Text(lastReplyAt, style: .relative)
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
      }
      
      HStack {
        if let subentryCount = discussion.discussionSubentryCount {
          HStack(spacing: 4) {
            Image(systemName: "bubble.left.and.bubble.right")
              .font(.caption)
            Text("\(subentryCount) replies")
              .font(.caption)
          }
          .foregroundColor(.secondary)
        }
        
        Spacer()
        
        if discussion.published == true {
          Text("Published")
            .font(.caption)
            .foregroundColor(.green)
        }
      }
    }
    .padding()
    .background(Color.systemGray6)
    .cornerRadius(12)
  }
}

// MARK: - Preview

struct CourseListView_Previews: PreviewProvider {
  static var previews: some View {
    CourseListView()
  }
}
