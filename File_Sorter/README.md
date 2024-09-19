# Automated File Organizer Script
Project Overview
This Python script is designed to automate the process of organizing downloaded files from the user's "Downloads" folder into categorized directories based on file types. The script moves files such as images, videos, documents, and others into designated folders for better file management and organization.

Problem Statement
The goal of this project is to:

Organize downloaded files by automatically moving them to specific folders based on their file types (e.g., images, videos, documents).
Ensure that directories are created dynamically if they do not exist.
Handle potential errors, such as permission issues, by implementing retries.
Walkthrough & Thought Process
During this project, the following steps were completed:

Path Setup:

The script sets up paths for the user's "Downloads" folder and the destination folder where sorted files will be moved.
The destination folder is dynamically expanded based on the user's home directory.
Logging & Folder Creation:

Logging is set up to record the operations, including successful moves, warnings, and errors.
Folders for various file categories (e.g., Images, Videos, Documents, etc.) are created if they don't exist.
File Movement:

The script scans the "Downloads" folder for all files.
It checks the file extension and moves files to the appropriate folder based on the extension.
Retries are implemented in case of permission errors when moving files.
Error Handling:

The script implements error handling for common issues, such as permission errors, with a retry mechanism.
Technologies Used
Python: for file manipulation and automation.
Logging: to track file operations and errors.
How to Run the Project
Clone the repository:

bash
Copy code
git clone https://github.com/Costaras/PortfolioProjects.git
cd PortfolioProjects/File_Organizer_Script/
Ensure the paths in the script match your system. Set the correct path for your downloads and destination directories:

python
Copy code
downloads_path = r"C:\\Users\\your_username\\Downloads"
destination_path = os.path.expanduser("~/Documents/_SortedFiles")
Run the script:

bash
Copy code
python file_organizer.py
The files from your "Downloads" folder will be moved to corresponding directories under the destination folder.

Project Structure
bash
Copy code
File_Organizer_Script/
├── file_organizer.py               # Python script for file organization
├── README.md                       # Project overview and instructions
Future Work
Extend the script to include custom folder categories based on user preferences.
Implement a feature to track duplicate files and handle them intelligently (e.g., rename or skip).
