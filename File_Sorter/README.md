# Automated File Organizer Script
## Project Overview
This Python script is designed to automate the process of organizing downloaded files from the user's "Downloads" folder into categorized directories based on file types. The script moves files such as images, videos, documents, and others into designated folders for better file management and organization.

## Problem Statement
The goal of this project is to:

1.Organize downloaded files by automatically moving them to specific folders based on their file types (e.g., images, videos, documents).
2.Ensure that directories are created dynamically if they do not exist.
3.Handle potential errors, such as permission issues, by implementing retries.

## Walkthrough & Thought Process
During this project, the following steps were completed:

1. **Path Setup:**

- The script sets up paths for the user's "Downloads" folder and the destination folder where sorted files will be moved.
- The destination folder is dynamically expanded based on the user's home directory.

2. **Logging & Folder Creation:**

- Logging is set up to record the operations, including successful moves, warnings, and errors.
- Folders for various file categories (e.g., Images, Videos, Documents, etc.) are created if they don't exist.

3. **File Movement:**

- The script scans the "Downloads" folder for all files.
- It checks the file extension and moves files to the appropriate folder based on the extension.
- Retries are implemented in case of permission errors when moving files.

4. **Error Handling:**

- The script implements error handling for common issues, such as permission errors, with a retry mechanism.

## Technologies Used
- **Python:** for file manipulation and automation.
- **Logging:** to track file operations and errors.

## How to Run the Project

1. Clone the repository:

```bash
git clone https://github.com/Costaras/PortfolioProjects.git
cd PortfolioProjects/File_Organizer_Script/
```

2. Ensure the paths in the script match your system. Set the correct path for your downloads and destination directories:

```python
downloads_path = r"C:\\Users\\your_username\\Downloads"
destination_path = os.path.expanduser("~/Documents/_SortedFiles")
```

3. Run the script:

```bash
python file_organizer.py
```

4. The files from your "Downloads" folder will be moved to corresponding directories under the destination folder.

Project Structure
```bash
File_Sorter/
├── notebooks
│   └── File_Sorter_walkthrough.ipynb  # Jupyter notebook walkthrough
├── scripts
│   └── Automatic_File_Sorter_V4.0.py  # Most up-to-date file sorting script
│   └── Automatic_File_Sorter_V3.7.py  # Previous file sorter itterations 
│   └── Automatic_File_Sorter_V3.6.py 
├── README.md                          # Project overview and instructions
```
Requirements
```bash
shutil
logging
time
```
## Future Work
- Extend the script to include custom folder categories based on user preferences.
- Implement a feature to track duplicate files and handle them intelligently (e.g., rename or skip).
