#!/usr/bin/env python
# coding: utf-8

# In[14]:


import os, shutil, logging, time

# Set up paths
downloads_path = r"C:\Users\conva\Downloads"
destination_path = os.path.expanduser("~/Documents/_SortedFiles")

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Define folder categories with subfolder structure
folders = {
    'Images': ('.png', '.jpg', '.jpeg'),
    'Videos': ('.mp4', '.mov', '.avi'),
    'GIFs': ('.gif',),
    'Documents': ('.pdf', '.docx', '.txt'),
    'Audio': ('.mp3', '.wav', '.ogg'),
    'Installers': ('.exe', '.msi', '.zip', '.rar'),
    'Datasets': {
        'CSV': ('.csv',),
        'Other': ('.xlsx', '.xls')
    },
    'Scripts': {
        'Python': ('.py',),
        'Other': ('.sh', '.bat', '.ps1', '.js', '.rb', '.php')
    },
    'JNotebooks': ('.ipynb',)
}

# Function to create folders
def create_folder(path):
    try:
        os.makedirs(path, exist_ok=True)
        logging.info(f"Ensured existence of directory: {path}")
    except Exception as e:
        logging.error(f"Error creating directory {path}: {e}")

# Create all folders and subfolders
for folder, contents in folders.items():
    main_folder_path = os.path.join(destination_path, folder)
    if isinstance(contents, dict):
        for subfolder in contents:
            create_folder(os.path.join(main_folder_path, subfolder))
    else:
        create_folder(main_folder_path)

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
    
    moved = False
    for folder, contents in folders.items():
        main_folder_path = os.path.join(destination_path, folder)
        
        # If the folder has subfolders for specific extensions
        if isinstance(contents, dict):
            for subfolder, extensions in contents.items():
                if file.lower().endswith(extensions):
                    destination = os.path.join(main_folder_path, subfolder, file)
                    moved = True
                    break
        else:  # If it's a main folder without subfolders
            if file.lower().endswith(contents):
                destination = os.path.join(main_folder_path, file)
                moved = True
                break
        
        if moved:
            try:
                if not os.path.exists(destination):
                    shutil.move(source, destination)
                    logging.info(f"Moved: {file} to {destination}")
                    files_moved += 1
                else:
                    logging.warning(f"File already exists: {destination}. Skipping.")
            except PermissionError as e:
                logging.error(f"Permission error moving file {file} to {destination}: {e}")
                time.sleep(60)  # Wait before retrying if needed
            except Exception as e:
                logging.error(f"Error moving file {file} to {destination}: {e}")
            break  # Stop checking other folders once a match is found

# Output the total number of files moved
logging.info(f"Total files moved: {files_moved}")


# In[ ]:




