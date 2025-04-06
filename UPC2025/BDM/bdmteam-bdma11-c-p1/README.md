# BDMProjectTeamFLH

## Overview
BDMProjectTeamFLH is a data engineering pipeline for student dropout risk prediction using Delta Lake, Spark (batch + streaming), and FastAPI. The system integrates structured, semi-structured, and unstructured data sources, supporting ranking at-risk students and clustering dropout types.

## Project Structure
```
bdm_project/
├── docker-compose.yml          # Main compose file
├── data/                       # ALL LOCAL DATA GOES HERE
│   ├── structured/             # Batch CSVs (vle.csv, students.csv, etc.)
│   └── log_data/               # Streaming CSVs (clean_df_*.csv)
├── api/                        # FastAPI container
│   ├── Dockerfile              # API-specific Dockerfile
│   ├── main.py                 # API code
│   └── requirements.txt        # Python dependencies
└── spark/                      # Spark container
    ├── Dockerfile              # Spark-specific Dockerfile
    └── ingest_data.py          # Streaming ingestion code
```

## Data Processing Workflow
1. **Batch Ingestion (FastAPI)**
    - Reads CSV files from `/data/structured/`
    - Converts them into Delta Lake tables stored in `/data/delta/`

2. **Streaming Processing (Spark)**
    - Monitors `/data/log_data/clean_df_*.csv`
    - Processes logs in real-time and stores them in `/data/delta/streaming_logs`

3. **Photo Processing (Kaggle API & Spark)**
    - Downloads student profile photos
    - Organizes them by `student_id`
    - Converts photos to binary and stores in Delta Lake `/data/delta/profile_photos`

## Running the Project

With Docker Desktop open, follow the steps:

### 1. Clone or download the project

### 2. Open the project folder in the terminal and clean the environment
```sh
docker compose down -v
```

### 3. Start the Containers
Run the following command to start the services:
```sh
docker compose up -d
```
This will launch the container stack, which includes:
- FastAPI for structured data ingestion
- Spark for batch and streaming data processing

### 3. Running Airflow Tasks
Once the containers are up, access the Airflow web UI. The first time it will require the usual admin admin for username and password.
```sh
http://localhost:8080
```
To execute tasks:
1. Navigate to the DAGs page
2. Enable and trigger the DAGs
3. Monitor logs and confirm task completion

### 4. Checking Processed Data
Once the pipeline runs successfully, the processed data will be available in the Delta Lake at `/data/delta/`
```sh
ls -lh ./data/delta
```

## Data Storage Structure
```
/data/delta/
├── profile_photos/                # Student profile photos (binary data)
├── batch_logs/                    # Processed batch log files
├── streaming_logs/                # Streaming log data
├── _checkpoints/                  # Streaming checkpoints
│   └── streaming/                 # Streaming job metadata
├── students/                      # Student data table
├── courses/                       # Course data table
├── assessments/                   # Assessment data table
├── studentVle/                    # Student VLE interactions
├── studentRegistration/           # Student registration records
├── studentAssessment/             # Student assessment results
├── student_course/                # Student-course relationships
├── healthcare_dataset_updated/    # Health data
├── students_mental_health_survey/ # Mental health data
└── vle/                           # Virtual Learning Environment data
```

## Stopping the Project
To stop and remove all running containers:
```sh
docker compose down -v
```


## Contributors
- Filipe Albuquerque Ito Russo
- HanLing Hu
- Lucia Victoria Fernandez Sanchez 


---
This project is part of the BDMA curriculum for BDM coursework.

