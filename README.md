# HaskMaintain

**HaskMaintain** is a Haskell application designed to analyze a Haskell codebase for maintainability. It traverses a given directory, analyzes each Haskell source file, and provides metrics like lines of code, function count, and cyclomatic complexity.

## Features

- Analyzes Haskell codebase for maintainability
- Provides metrics like lines of code, function count, and cyclomatic complexity
- Generates a comprehensive report

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/your-username/HaskMaintain.git
    cd HaskMaintain
    ```

2. Install dependencies and build the project:
    ```bash
    stack setup
    stack build
    ```

## Usage

1. Run the application:
    ```bash
    stack run HaskMaintain <path-to-codebase>
    ```

2. The application will generate a report with code complexity and maintainability metrics.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
