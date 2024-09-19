
# Best-Selling Video Games Data Preparation

## Project Overview

This project focuses on scraping data from [Wikipedia's Best-Selling Video Games](https://en.wikipedia.org/wiki/List_of_best-selling_video_games) and cleaning it for future analysis. The goal was to transform raw HTML data into a structured, ready-to-analyze format.

## Problem Statement

The goal of this project is to:
1. Scrape the list of best-selling video games from Wikipedia.
2. Clean and structure the data into a CSV format.
3. Prime the dataset for future analysis such as identifying sales trends, popular platforms, and leading publishers.

## Walkthrough & Thought Process

During this project, the following steps were completed:
1. **Web Scraping**:
   - Scraped the table from Wikipedia using `BeautifulSoup` and `requests`.
   - Extracted key attributes like game titles, sales figures, platforms, release dates, developers, and publishers.

2. **Data Cleaning**:
   - Used regular expressions to clean unwanted symbols from text (e.g., parentheses and references).
   - Manually handled missing sales values where data was unavailable.

3. **Priming for Future Analysis**:
   - The data is saved as a clean CSV file, ready for further analysis, such as grouping by developers, platforms, or identifying trends over time.

## Technologies Used

- **Python**: for web scraping and data preparation.
- **Pandas**: for data manipulation.
- **BeautifulSoup**: for web scraping.

## How to Run the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/Costaras/PortfolioProjects.git
   cd PortfolioProjects/Best_selling_video_games/
   ```

2. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the scraper script:
   ```bash
   python scripts/scraper.py
   ```

4. The cleaned data will be saved as `best_selling_video_games.csv` in the `data/` folder.

## Project Structure

```
Best_selling_video_games/
├── data
│   └── best_selling_video_games.csv   # Cleaned data for analysis
├── notebooks
│   └── data_preparation_walkthrough.ipynb  # Jupyter notebook walkthrough
├── scripts
│   └── scraper.py                     # Web scraping script
├── README.md                          # Project overview and instructions
```
Requirements
```bash
BeautifulSoup #from bs4
requests
pandas
re
```
## Future Work

- Perform detailed data analysis (e.g., trends, publisher performance, platform-specific insights).
- Visualize sales distribution across platforms and publishers.
