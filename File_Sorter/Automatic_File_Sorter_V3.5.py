#!/usr/bin/env python
# coding: utf-8

"""
Automatic File Sorter

This script moves files from the specified source directory to defined destination folders
based on file extensions. It handles error checks for existing files, permission issues,
and files being used by another process.
"""

import os
import shutil
import logging
import time

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Paths
downloads_path = r"C:\Users\conva\Downloads"
destination_path = os.path.expanduser("~/Documents/_SortedFiles")

# File type folders
folders = {
    'Images': ('.png', '.jpg', '.jpeg'),
    'Videos': ('.mp4', '.mov', '.avi'),
    'GIFs': ('.gif',),
    'Documents': ('.pdf', '.docx', '.txt'),
    'Audio': ('.mp3', '.wav', '.ogg'),
    'Installers': ('.exe', '.msi', '.zip', '.rar'),
    'CSV': ('.csv',),
    'Scripts': ('.py', '.sh', '.bat', '.ps1', '.js', '.rb', '.php')
}

# Create destination folders if they don't exist
for folder in folders:
    folder_path = os.path.join(destination_path, folder)
    try:
        os.makedirs(folder_path, exist_ok=True)
        logging.info(f"Ensured existence of directory: {folder_path}")
    except Exception as e:
        logging.error(f"Error creating directory {folder_path}: {e}")

# List files in the source directory
file_names = os.listdir(downloads_path)
files_moved = 0

# Move files to appropriate folders
for file in file_names:
    source = os.path.join(downloads_path, file)
    
    # Skip directories
    if os.path.isdir(source):
        continue
    
    for folder, extensions in folders.items():
        if file.lower().endswith(extensions):
            destination = os.path.join(destination_path, folder, file)
            
            # Attempt to move the file with retries
            max_retries = 3
            retry_count = 0
            
            while retry_count < max_retries:
                try:
                    if not os.path.exists(destination):
                        shutil.move(source, destination)
                        logging.info(f"Moved: {file} to {folder}")
                        files_moved += 1
                    else:
                        logging.warning(f"File already exists: {destination}. Skipping.")
                    break
                except PermissionError as e:
                    retry_count += 1
                    logging.error(f"Permission error moving {file} to {folder}: {e}. Retrying {retry_count}/{max_retries}.")
                    time.sleep(60)  # Wait before retrying
                except Exception as e:
                    logging.error(f"Error moving {file} to {folder}: {e}")
                    break
            break

# Summary of operations
logging.info(f"Total files moved: {files_moved}")
