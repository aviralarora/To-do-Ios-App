import SwiftUI

// Define a structure to represent a task
struct Task: Identifiable, Codable, Equatable {
    var id = UUID() // Unique identifier for each task
    var title: String // Title of the task
    var isCompleted: Bool = false // Flag to track if the task is completed or not

    // Function to compare tasks based on their IDs
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
    }
}

// Create a class to manage tasks
class TaskManager: ObservableObject {
    // Published property to automatically update views when tasks change
    @Published var tasks: [Task] = [] // An array to store tasks
    
    // Initialize TaskManager and load tasks from UserDefaults
    init() {
        loadTasks()
    }
    
    // Function to load tasks from UserDefaults
    func loadTasks() {
        if let savedTasks = UserDefaults.standard.data(forKey: "tasks") {
            let decoder = JSONDecoder()
            if let loadedTasks = try? decoder.decode([Task].self, from: savedTasks) {
                self.tasks = loadedTasks
            }
        }
    }
    
    // Function to save tasks to UserDefaults
    func saveTasks() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }
    
    // Function to add a new task to the tasks array and save tasks
    func addTask(title: String) {
        let newTask = Task(title: title)
        tasks.append(newTask)
        saveTasks()
    }
    
    // Function to delete a task at the specified index and save tasks
    func deleteTask(at index: IndexSet) {
        tasks.remove(atOffsets: index)
        saveTasks()
    }
    
    // Function to toggle the completion status of a task at the specified index and save tasks
    func toggleTaskCompleted(at index: Int) {
        tasks[index].isCompleted.toggle()
        saveTasks()
    }
}

// Main ContentView structure
struct ContentView: View {
    // Create an instance of TaskManager and bind it to the view's state
    @StateObject var taskManager = TaskManager()
    @State private var newTaskTitle = "" // Store the new task title
    
    var body: some View {
        NavigationView {
            List {
                // Display tasks in a list
                ForEach(taskManager.tasks) { task in
                    TaskRow(task: task) {
                        taskManager.toggleTaskCompleted(at: taskManager.tasks.firstIndex(of: task)!)
                    }
                }
                .onDelete(perform: taskManager.deleteTask) // Enable deleting tasks
            }
            .navigationTitle("To-Do List") // Set the navigation title
            .navigationBarItems(trailing:
                NavigationLink(destination: AddTaskView(taskManager: taskManager)) {
                    Text("Add") // Add a button to navigate to AddTaskView
                }
            )
        }
        .environment(\.colorScheme, .dark) // Optional: Dark Mode implementation
    }
}

// TaskRow structure to display each task in the list
struct TaskRow: View {
    var task: Task
    var toggleTask: () -> Void
    
    var body: some View {
        HStack {
            // Button to toggle task completion status
            Button(action: toggleTask) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
            }
            .buttonStyle(PlainButtonStyle())
            
            // Display task title with strikethrough if completed
            Text(task.title)
                .strikethrough(task.isCompleted, color: .gray)
            
            Spacer() // Add spacing at the end of the row
        }
    }
}

// AddTaskView structure to add new tasks
struct AddTaskView: View {
    // Bind the task manager to the view's state
    @StateObject var taskManager: TaskManager
    @State private var newTaskTitle = "" // Store the new task title
    
    var body: some View {
        VStack {
            // Textfield to input new task title
            TextField("Enter task", text: $newTaskTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Button to add a new task
            Button(action: {
                if !newTaskTitle.isEmpty {
                    taskManager.addTask(title: newTaskTitle)
                    newTaskTitle = "" // Clear the input field after adding the task
                }
            }) {
                Text("Add Task")
            }
            .padding()
            .disabled(newTaskTitle.isEmpty) // Disable the button if the input field is empty
            
            Spacer() // Add spacing at the bottom of the view
        }
        .navigationTitle("New Task") // Set the navigation title
    }
}

// Preview provider for ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

