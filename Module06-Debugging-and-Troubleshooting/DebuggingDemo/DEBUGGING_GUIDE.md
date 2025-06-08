# Exercise 1: Debugging Fundamentals

## 🎯 Objective
Master debugging tools and techniques in ASP.NET Core applications.

## ⏱️ Time Allocation
**Total Time**: 25 minutes
- Environment Setup: 5 minutes
- Basic Debugging: 10 minutes
- Advanced Techniques: 10 minutes

## 🚀 Getting Started

### Step 1: Set Up Debugging Environment
1. Open the project in VS Code or Visual Studio
2. Ensure the debugger is configured (check .vscode/launch.json)
3. Build the project: `dotnet build`
4. Start debugging: F5 or "Run and Debug" in VS Code

### Step 2: Basic Breakpoint Debugging
1. Set a breakpoint in `TestController.GetUsers()` method
2. Call the endpoint: `GET /api/test/users`
3. Inspect the `_users` collection in the debugger
4. Step through the LINQ query execution

### Step 3: Conditional Breakpoints
1. Set a conditional breakpoint in `GetUser(int id)` method
2. Condition: `id == 2`
3. Call: `GET /api/test/users/1` (should not break)
4. Call: `GET /api/test/users/2` (should break)

### Step 4: Exception Debugging
1. Set a breakpoint in `CreateUser()` method
2. Send a POST request with empty name
3. Step through the exception handling
4. Examine the exception details

### Step 5: Watch Variables and Call Stack
1. Set breakpoints in `CalculateOrderTotal()` method
2. Add watches for: `order.Items`, `total`, `item.Price * item.Quantity`
3. Step through the calculation loop
4. Examine the call stack

## 🔧 Debugging Techniques to Practice

### Breakpoint Types
- **Line breakpoints**: Basic pause points
- **Conditional breakpoints**: Break only when condition is true
- **Hit count breakpoints**: Break after N hits
- **Function breakpoints**: Break when entering specific methods

### Variable Inspection
- **Locals window**: See all local variables
- **Watch window**: Monitor specific expressions
- **Immediate window**: Execute code during debugging
- **DataTips**: Hover over variables to see values

### Navigation
- **Step Over (F10)**: Execute current line
- **Step Into (F11)**: Enter method calls
- **Step Out (Shift+F11)**: Exit current method
- **Continue (F5)**: Resume execution

## 🧪 Debugging Exercises

### Exercise A: Find the Display Name Bug
1. Set breakpoint in `User.GetDisplayName()`
2. Create a user with null email
3. Debug the null reference exception
4. Fix the method to handle null values

### Exercise B: Debug Order Calculation
1. Create an order with multiple items
2. Set breakpoints in `CalculateTotal()`
3. Watch the running total calculation
4. Verify the math is correct

### Exercise C: Performance Debugging
1. Set breakpoint in `SlowOperation()`
2. Use the stopwatch to measure performance
3. Identify the slow operation
4. Consider optimization strategies

## ✅ Success Criteria
- [ ] Can set and use different types of breakpoints
- [ ] Comfortable with variable inspection tools
- [ ] Can navigate through code during debugging
- [ ] Able to debug exceptions effectively
- [ ] Understands call stack analysis

## 🔄 Next Steps
After mastering basic debugging, move on to Exercise 2 for logging implementation.

