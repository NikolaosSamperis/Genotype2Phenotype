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
│── README.md       # Project Documentation
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
   git clone https://github.com/bpulugundla/Genotype2Phenotype.git
   cd Genotype2Phenotype
   ```
2. Import the database schema:
   ```sh
   mysql -u root -p < database/dcdm_project_final.sql
   ```

### **Running the RShiny Dashboard**
1. Open `dashboard/app.R` in RStudio.
2. Run the app using:
   ```r
   shiny::runApp()
   ```

## License
This project is for educational purposes as part of coursework. Feel free to use and modify the code with proper attribution.

## Collaborators & Contributions
This project is developed as part of a group coursework for the data cleaning and data management module. Contributions include database design, R programming, statistical analysis, and dashboard development.

**Understanding the Role of Every Mouse Gene – One Knockout at a Time!** 
