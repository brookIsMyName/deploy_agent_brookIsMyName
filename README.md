# Project Deployment Agent

## Overview

The Project Deployment Agent is a Bash automation tool that deploys and manages student attendance-tracking projects. It automates project setup, configures attendance thresholds, runs existing projects, and archives generated log files.

## Features

- It first verifies that Python 3 and `zip` are installed before starting.
- It can easily Copy a selected number of existing student records or create a fresh sample roster.
- Auto makes the Python application executable and restricts access to the configuration file.
- Allows the user to configure warning and failure attendance thresholds.
- Executes the attendance checker for a selected project.
- It can copy attendance and absence logs into separate, timestamped archive directories.
- During deployment, it can handle Ctrl+C and Ctrl+Z by attempting to back up the incomplete project into a ZIP archive.

## Requirements

- Ubuntu or another Linux environment with Bash
- Python 3
- `zip`
- and the project files itself

## Project Structure

```text
deploy_agent_brookIsMyName/
├── deploy_agent.sh
├── README.md
├── .gitignore
└── templates/
    ├── attendance_checker.py
    ├── assets.csv
    └── config.json
```

A deployed project follows this structure:

```text
attendance_tracker_<name>/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
├── reports/
└── archives/
    ├── attendance/
    └── absent/
```

The `archives/` directories are created when the archive option is used.

## Video Demonstration

** The following links provide a demonstration of the Project Deployment Agent:**

1. YouTube: https://youtu.be/JSqLfRWJzeI

2. Google Drive backup: https://drive.google.com/file/d/1d7XJQVyuwZdgvakkRN96AQSFlhhaa9pN/view?usp=sharing


## Installation

1. Clone or download this repository.
2. Open a terminal and navigate to the project directory.
3. Ensure the deployment script is executable:

   ```bash
   chmod +x deploy_agent.sh
   ```

4. Check that the required dependencies are installed:

   ```bash
   python3 --version
   zip -v
   ```

## Usage

Start the deployment agent from the repository directory:

```bash
./deploy_agent.sh
```

Follow the menu prompts.

### Option 1: Deploy a new project

1. Enter a project name.
2. If the project directory already exists, choose whether to overwrite it or cancel.
3. Select a roster option:

##### PLEASE MAKE SURE NOT TO SAY MORE THAT 4 STUDENTS, as that is the max number of student records we have for this assignment :)
   - **A Existing roster:** Choose how many student records to copy from the template.
   - **B Fresh roster:** Generate a sample roster with zero attendance and absence counts.
4. Enter the warning threshold between 0 and 100.
5. Enter the failure threshold between 0 and 100, ensuring it is lower than the warning threshold.

The deployment agent creates the project directories, copies the templates, sets file permissions, and updates the configuration.

### Option 2: Run an existing project

Enter the project name when prompted. The agent checks that the project directory and `attendance_checker.py` exist before running the attendance checker with Python 3.

The attendance checker collects attendance information and generates reports in the project's `reports/` directory.

### Option 3: Archive generated logs

Enter the project name. The agent checks for the attendance and absence logs and copies any existing logs into separate archive directories using timestamped filenames.

Example archive filenames:

```text
archives/attendance/attendance_YYYYMMDD_HHMMSS.log
archives/absent/absent_YYYYMMDD_HHMMSS.log
```

If a log does not exist, the agent reports that it was not found and continues checking the other log. Original report files are preserved because the script copies them.

### Option 4: Exit

Exits the deployment agent.

## Configuration

The deployed `Helpers/config.json` file contains the attendance thresholds and other application settings.

Example:

```json
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 5
}
```

- `warning`: Attendance percentage at which a warning may be triggered.
- `failure`: Attendance percentage below which the student may be considered at risk of failing.
- `run_mode`: Application run mode.
- `total_sessions`: Total number of sessions configured for the attendance tracker.

The warning and failure thresholds must be between 0 and 100, with the failure threshold lower than the warning threshold.

## Testing

Check the Bash syntax with:

```bash
bash -n deploy_agent.sh
```

Run the script and test the menu options, including:

- Deploying a new project.
- Creating a fresh roster and copying an existing roster.
- Configuring valid and invalid thresholds.
- Running an existing project.
- Archiving logs when both logs exist and when one or both are missing.
- Handling an existing project directory.
- Interrupting deployment with Ctrl+C or Ctrl+Z.

## Notes

- Use unique project names when creating separate test projects.
- Generated test projects and ZIP archives are excluded from Git using `.gitignore`.
- Do not commit real student or other sensitive personal data to the repository.
- An interrupted deployment attempts to create a ZIP backup before removing the incomplete project directory.
