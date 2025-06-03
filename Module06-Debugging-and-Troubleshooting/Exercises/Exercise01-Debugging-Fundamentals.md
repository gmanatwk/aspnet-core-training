# Exercise 1: Setting Up Debugging Environment

## 🎯 Objective
Master debugging tools and techniques in ASP.NET Core applications using Visual Studio or VS Code.

## ⏱️ Estimated Time
25 minutes

## 📚 Prerequisites
- Basic understanding of ASP.NET Core
- Visual Studio 2022 or VS Code with C# extension
- .NET 8 SDK installed

## 🔧 Setup
Use the DebuggingDemo project from the SourceCode folder for this exercise.

## 📋 Tasks

### Task 1: Environment Setup (5 minutes)
1. **Open the DebuggingDemo project** in your preferred IDE
2. **Restore packages** and build the project
3. **Run the application** and verify it starts correctly
4. **Access Swagger UI** at `https://localhost:5001/swagger`

### Task 2: Basic Breakpoint Debugging (10 minutes)
1. **Set a breakpoint** in the `TestController.Ping()` method
2. **Call the endpoint** using Swagger or your browser
3. **Practice inspection**:
   - Examine local variables
   - Check the call stack
   - Use the watch window to monitor `DateTime.UtcNow`
4. **Step through code** using F10 (Step Over) and F11 (Step Into)

### Task 3: Conditional Breakpoints (5 minutes)
1. **Set a conditional breakpoint** in the `TestController.SlowResponse()` method
2. **Configure condition**: `delayMs > 1000`
3. **Test the breakpoint**:
   - Call `/api/test/slow/500` (should not break)
   - Call `/api/test/slow/2000` (should break)

### Task 4: Exception Debugging (5 minutes)
1. **Enable "Break when thrown"** for all exceptions in your debugger
2. **Call the error endpoint**: `/api/test/error/argument`
3. **Examine exception details**:
   - Exception type and message
   - Stack trace
   - Inner exceptions
4. **Practice exception handling** by stepping through the global exception middleware

## 🧪 Test Cases

### Test Case 1: Basic Debugging
```http
GET /api/test/ping
```
**Expected**: Breakpoint hits, you can inspect variables

### Test Case 2: Conditional Breakpoint
```http
GET /api/test/slow/2000
```
**Expected**: Breakpoint hits only when delay > 1000ms

### Test Case 3: Exception Debugging
```http
GET /api/test/error/argument
```
**Expected**: Exception caught in debugger, middleware handles it gracefully

## 💡 Debugging Techniques to Practice

### 1. Variable Inspection
- **Immediate Window**: Execute code during debugging
- **Watch Window**: Monitor specific variables
- **Locals Window**: View all local variables
- **DataTips**: Hover over variables for quick inspection

### 2. Breakpoint Types
- **Line Breakpoints**: Break at specific lines
- **Conditional Breakpoints**: Break only when conditions are met
- **Hit Count Breakpoints**: Break after N executions
- **Function Breakpoints**: Break when entering specific methods

### 3. Call Stack Analysis
- **Navigate call stack**: Click different stack frames
- **Understand execution flow**: Trace how code was reached
- **Switch contexts**: View variables in different stack frames

## 🔍 Advanced Debugging Features

### Hot Reload (for supported scenarios)
1. **Make a change** to the `Ping()` method return message
2. **Save the file** and observe hot reload in action
3. **Test the endpoint** to see the change without restart

### Remote Debugging Setup
1. **Configure for remote debugging** (if available)
2. **Attach to process** for live debugging
3. **Debug running applications** without stopping them

## 📊 Expected Outcomes
After completing this exercise, you should be able to:
- ✅ Set and configure different types of breakpoints
- ✅ Inspect variables and navigate call stacks effectively
- ✅ Debug exceptions and understand error flows
- ✅ Use advanced debugging features like conditional breakpoints
- ✅ Apply debugging techniques to real-world scenarios

## 🚨 Common Issues & Solutions

### Issue 1: Breakpoints Not Hitting
**Cause**: Debug symbols not loaded or optimized build
**Solution**: Ensure Debug configuration and rebuild project

### Issue 2: Variables Show "Cannot evaluate"
**Cause**: Optimized code or variables out of scope
**Solution**: Check call stack context and ensure Debug build

### Issue 3: Hot Reload Not Working
**Cause**: Unsupported changes or configuration issues
**Solution**: Restart application or check Hot Reload settings

## 🎓 Bonus Challenges

### Challenge 1: Advanced Breakpoint
Set a breakpoint in the `ExternalApiService.GetDataAsync()` method that only breaks when:
- `id` parameter is less than 5
- The current time is during business hours (9 AM - 5 PM)

### Challenge 2: Multi-threaded Debugging
1. Call multiple slow endpoints simultaneously
2. Practice debugging across different threads
3. Observe thread switching in the debugger

### Challenge 3: Memory Debugging
1. Use the memory usage tools in Visual Studio
2. Call the memory test endpoint with different sizes
3. Observe memory allocation and garbage collection

## 📝 Reflection Questions
1. When would you use conditional breakpoints vs. regular breakpoints?
2. How can debugging help you understand performance issues?
3. What debugging techniques are most useful for production troubleshooting?

## 🔄 Next Steps
Once you've mastered basic debugging, proceed to:
- **Exercise 2**: Comprehensive Logging Implementation
- **Module 7**: Testing Applications (debugging tests)
- **Advanced debugging scenarios** in production environments

---

**💡 Pro Tip**: Practice debugging regularly with real scenarios. The more comfortable you become with debugging tools, the faster you'll be able to identify and fix issues in production applications.
