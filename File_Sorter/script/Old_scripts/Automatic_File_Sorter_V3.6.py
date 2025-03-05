#!/usr/bin/env python
# coding: utf-8

# In[2]:


import os, shutil, logging, time

# Set up paths
downloads_path = r"C:\Users\conva\Downloads"
destination_path = os.path.expanduser("~/Documents/_SortedFiles")

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Define folder categories and file extensions
folders = {
    'Images': ('.png', '.jpg', '.jpeg'),
    'Videos': ('.mp4', '.mov', '.avi'),
    'GIFs': ('.gif',),
    'Documents': ('.pdf', '.docx', '.txt'),
    'Audio': ('.mp3', '.wav', '.ogg'),
    'Installers': ('.exe', '.msi', '.zip', '.rar'),
    'CSV': ('.csv',),
    'Scripts': ('.py', '.sh', '.bat', '.ps1', '.js', '.rb', '.php'),
    'JNotebooks': ('.ipynb',)
}

# Create folders if they don't exist
for folder in folders:
    folder_path = os.path.join(destination_path, folder)
    try:
        os.makedirs(folder_path, exist_ok=True)  # Create folders if they do not exist
        logging.info(f"Ensured existence of directory: {folder_path}")
    except Exception as e:
        logging.error(f"Error creating directory {folder_path}: {e}")

# List all files in the downloads directory
file_names = os.listdir(downloads_path)

# Initialize count of moved files
files_moved = 0

# Move files based on their extensions
for file in file_names:
    source = os.path.join(downloads_path, file)
    
    # Skip directories (folders)
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
                    break  # Exit the loop if successful
                except PermissionError as e:
                    retry_count += 1
                    logging.error(f"Permission error moving file {file} to {folder}: {e}. Retrying {retry_count}/{max_retries}.")
                    time.sleep(60)  # Wait 1 minute before retrying
                except Exception as e:
                    logging.error(f"Error moving file {file} to {folder}: {e}")
                    break  # Exit on other exceptions
            break  # Stop checking other folders once a match is found

# Output the total number of files moved
logging.info(f"Total files moved: {files_moved}")


# In[ ]:




