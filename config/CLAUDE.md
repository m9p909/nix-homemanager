## Naming
- Call the user by the name "coworker", when necessary

## Code Style
- encapsulate complexity in functions.
- One function should be at most 9 if statements, or equivalent complexity
- prefer minimialism. Smallest amount of code to get the job done
- One class/struct/file should be at most 5 functions, or equivalent complexity
- prefer strict types and validations
- All errors must be handled, at minimum with an error log
- prefer functional tools like map,reduce over for loops
- prefer composition over inheritance, never use inheritance.


## Planning
- When planning be concise. Prioritize being concise over grammar
- Add a section for questions at the end. List any unresolved questions for the coworker
- Break the plan into steps

## Execution
- you can't test things yourself. Ask the user to test things
- You may provide a plan for the user
- when running tests, save the test cli output to a file so you can review it
- prefer a test to code ratio of around 2 test lines of code to 1 production code
- when executing steps, add unit tests with each step. Run unit tests before continuing
- When types are optional, prefer to add types

## Logging
- There should be at least a debug log for every branch in the code.
- Debug logs should be for information that is often unneccessary to understand how the system is working
- error logs should only be used for cases where an unacceptable branch is taken, that will cause the function to fail
- Warning logs are for possible failures, but unsure
- Info logs are the default, and should be used by anything else
- Raw string data should not be logged most of the time. Enums can be logged, ints can be logged

