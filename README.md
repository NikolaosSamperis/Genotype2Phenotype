[![R‑Shiny](https://img.shields.io/badge/R–Shiny-%23ED5986?logo=R)](https://shiny.rstudio.com/)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![RMySQL](https://img.shields.io/badge/RMySQL-%23007A99)](https://cran.r-project.org/package=RMySQL)
[![DBI](https://img.shields.io/badge/DBI-%23DB4C3F)](https://cran.r-project.org/package=DBI)
[![dplyr](https://img.shields.io/badge/dplyr-%232C496E?logo=r&logoColor=white)](https://cran.r-project.org/package=dplyr)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)


# Genotype2Phenotype
**Genotype2Phenotype** is a data-driven project aimed at exploring the impact of gene knockouts on mouse phenotypes using statistical analysis, database management, and interactive visualizations.

## Project Overview
This repository contains scripts and resources for:
- **Data Cleaning & Processing**: Ensuring accuracy and consistency in IMPC phenotypic data.
- **Database Creation & Management**: Designing and implementing a scalable MySQL database to store genotype-phenotype associations.
- **Interactive Dashboard**: Developing an RShiny application to visualize gene knockout effects on phenotypes.

## Features
- **Query mouse genotype-phenotype data** with MySQL.
- **Visualize phenotype significance scores** for different gene knockouts.
- **Identify clusters of genes** with similar phenotypic effects.

## Technologies Used
- **R** (Data Processing & Visualization)
- **MySQL** (Database Management)
- **RShiny** (Interactive Dashboard)

## Repository Structure
```
Genotype2Phenotype
│── data          # Processed phenotype data files
│── scripts       # R scripts for data cleaning & visualization
│── database      # SQL scripts for database setup
│── dashboard     # RShiny app for data exploration
│── README.md     # Project Documentation
```

## Visualizations
The RShiny dashboard provides three key visualizations:
1. **Gene Knockout Analysis** – Select a specific knockout mouse and visualize the affected phenotypes.
2. **Phenotype-Wide Analysis** – View statistical scores of all knockouts for a selected phenotype.
3. **Gene Clustering** – Identify genes with similar phenotype impact based on statistical scores.

## Setup & Installation
### **Prerequisites**
Ensure you have the following installed:
- R and RStudio
- MySQL Server

### **Database Setup**
1. Clone this repository:
   ```sh
   git clone https://github.com/NikolaosSamperis/Genotype2Phenotype.git
   cd Genotype2Phenotype
   ```
2. Import the database schema:
   ```sh
   mysql -u root -p < database/dcdm_project_group9.sql
   ```

### **Running the RShiny Dashboard**
1. Open `dashboard/app.R` in RStudio.
2. Run the app using:
   ```r
   shiny::runApp()
   ```

### **Data Preparation**
If interested in running data cleaning/collation and database creation, do the following:
1. Run the data reading and collation script:
   ```r
   rmarkdown::render("scripts/data_reading.qmd")
   ```
   Jupyter Notebook (Python alternative):
   ```sh
   jupyter notebook scripts/data_cleaning.ipynb
   ```
2. Manage the database:
   ```r
   rmarkdown::render("scripts/dbms.Rmd")
   ```

## Collaborators & Contributions
This project is developed as part of a group coursework for the *Data Cleaning and Data Management* module. Thanks to my group members for their help on this project.
- Bhargav Pulugundla
- Aidan Saldanha 
- Harit Kohli

Contributions include database design, R programming, statistical analysis, and dashboard development.

## License
This project was created for educational purposes as part of coursework.

Feel free to use, modify, and share the code **with proper attribution**. Please note that this project is provided **as-is**, without any warranty or guarantee of functionality.

If you use this code, kindly credit the original author by linking back to this repository.

**Understanding the Role of Every Mouse Gene – One Knockout at a Time!** 
