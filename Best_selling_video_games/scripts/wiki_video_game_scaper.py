#!/usr/bin/env python
# coding: utf-8

# In[4]:


# Importing necessary packages
from bs4 import BeautifulSoup
import requests
import pandas as pd
import re

# Define the URL for the Wikipedia page to scrape
url = 'https://en.wikipedia.org/wiki/List_of_best-selling_video_games'

# Sending a request to the URL and getting the page content
page = requests.get(url)
content = BeautifulSoup(page.text, 'html')

# Scraping the table attributes
table = content.find_all('table')[1]
headers = table.find_all('th', scope='col')

# Clean the table attributes
def clean_text(text):
    # Regex to remove patterns like '(s)', '[b]', etc.
    return re.sub(r'\(.*?\)|\[.*?\]', '', text).strip()

# Creating table attributes
table_attributes = [clean_text(attribute.text.strip()) for attribute in headers]

# Create the table as a DataFrame
df = pd.DataFrame(columns=table_attributes)

# Scraping the table rows
rows = table.find_all('tr')

# Appending data into the DataFrame
for row in rows[1:]:
    row_data = row.find_all(['th', 'td'])
    observation = [data.text.strip() for data in row_data]
    if len(observation) == len(df.columns) - 1:  # If the row length matches the column length
        observation.insert(1, None)
    observation_df = pd.DataFrame([observation], columns=df.columns)
    df = pd.concat([df, observation_df], ignore_index=True)


# Handling missing sales values manually
missing_sales_values = [
    50000000, 50000000,  # First 2 games
    30000000, 30000000,  # Next 2
    28000000,            # Next 1
    26500000,            # Next 1
    25000000, 25000000, 25000000,  # Next 3
    24000000             # Last 1
]

# Find indices of rows with missing Sales values
missing_sales_rows = df[df['Sales'].isna()]

# Fill in missing Sales values based on the provided sequence
for i, index in enumerate(missing_sales_rows.index):
    df.at[index, 'Sales'] = missing_sales_values[i]

# Save the DataFrame to a CSV file
df.to_csv(r'C:\Users\conva\Documents\_SortedFiles\CSV\Best_Selling_Video_Games.csv', index=False)


# In[ ]:




