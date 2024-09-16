#!/usr/bin/env python
# coding: utf-8

# # Automatic File Sorter
# 
# 

# This is automatic file sorter moves files from one directory to the prefered destination.
# 
# <ins>Checks</ins> for errors:
# 
# - If *files* and *folders* created already exist in the directories. 
# - Permission errors.    
# - *Files* being used by another process.

# In[39]:


import os, shutil, logging, time


# In[41]:


path = r"C:/Users/conva/Downloads/"


# ### Set up logging

# In[44]:


logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


# ### Destination paths

# In[47]:


downloads_path = r"C:\Users\conva\Downloads" 


# In[49]:


destination_path = os.path.expanduser("~/Documents/_SortedFiles")


# ### Defining folders
# 
# Can be edited to *add* or *remove* files

# In[52]:


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


# ### Creating the folders

# Only if they don't exist

# In[56]:


for folder in folders:
    folder_path = os.path.join(destination_path, folder)
    try:
        os.makedirs(folder_path, exist_ok=True)  # Create folders if they do not exist
        logging.info(f"Ensured existence of directory: {folder_path}")
    except Exception as e:
        logging.error(f"Error creating directory {folder_path}: {e}")


# #### List of files in the directory

# In[59]:


file_names = os.listdir(downloads_path)


# ### Transferring files

# Only if they are not already in the folder

# In[37]:


# Initialize count of moved files
files_moved = 0


# In[61]:


# Transferring files
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
                    logging.error(f"Permission error moving file {file} to {folder}: {e}. File might be in use. Retrying {retry_count}/{max_retries}.")
                    time.sleep(60)  # Wait 1 minute before retrying
                except Exception as e:
                    logging.error(f"Error moving file {file} to {folder}: {e}")
                    break  # Exit on other exceptions
            break  # Stop checking other folders once a match is found


# ### Summary of operations

# In[64]:


logging.info(f"Total files moved: {files_moved}")

