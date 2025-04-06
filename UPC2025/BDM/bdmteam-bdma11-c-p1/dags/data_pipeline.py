from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.utils.trigger_rule import TriggerRule
from docker.types import Mount
import requests

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'email_on_failure': True
}

with DAG(
    'delta_lake_data_pipeline',
    default_args=default_args,
    schedule_interval='@daily',
    start_date=datetime(2025, 1, 1),
    catchup=False,
    max_active_runs=3,  
    concurrency=10,
    tags=['spark', 'delta_lake']
) as dag:
    
    # Task 1:
    ingest_via_api = BashOperator(
        task_id='ingest_via_api',
        bash_command="""
                    for d in students courses assessments vle studentVle student_course \
                    studentRegistration studentAssessment healthcare_dataset_updated \
                    students_mental_health_survey; do
        curl -fsS --retry 3 --retry-delay 5 \
             -X POST "http://api:8000/ingest?dataset=${d}" || exit 1
    done
    """,
        env={
            'WAIT_HOSTS': 'api:8000',
            'WAIT_TIMEOUT': '60'
    }
)
        
    # Task 2: Process photos
    process_photos = BashOperator(
        task_id='process_profile_photos',
        bash_command="""
    docker exec bdmteam-bdma11-c-p1-spark-1 \
    bash -c 'cd /app && /opt/bitnami/python/bin/python ingest_data.py --mode=photos || exit 1'
    """
)

    # Task 3: Process batch logs
    process_batch = BashOperator(
        task_id='process_batch_logs',
        bash_command="""
    docker exec bdmteam-bdma11-c-p1-spark-1 \
    bash -c 'cd /app && /opt/bitnami/python/bin/python ingest_data.py --mode=batch || exit 1'
    """
)



    # Task 4: Start streaming 
    start_streaming = BashOperator(
        task_id='start_log_streaming',
        bash_command="""
    docker exec bdmteam-bdma11-c-p1-spark-1 \
    bash -c 'cd /app && /opt/bitnami/python/bin/python ingest_data.py --mode=streaming || exit 1'
    """,
        env={
            'DELTA_LAKE_PATH': '/data/delta',
            'LOG_DATA_PATH': '/data/log_data'
    }
    )

    # Task 5: Health check
    def check_streaming_health():
        """Check if streaming application is running"""
        try:
            response = requests.get("http://spark:4040/api/v1/applications", timeout=10)
            apps = response.json()
            return any('StreamingQuery' in app.get('name', '') for app in apps)
        except Exception as e:
            print(f"Health check failed: {str(e)}")
            return False

    streaming_health_check = PythonOperator(
        task_id='verify_streaming_health',
        python_callable=check_streaming_health,
        retries=2,
        retry_delay=timedelta(minutes=1))
    
    # Task 6: Notifications
    send_notification = BashOperator(
        task_id='send_completion_notification',
        bash_command='echo "Pipeline completed successfully" | mail -s "Delta Lake Pipeline Status" admin@example.com',
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    # Workflow definition

    ingest_via_api >> process_photos
    process_photos >> process_batch 

    # After batch processing completes:
    process_batch >> [start_streaming, streaming_health_check]

    # Streaming and health check run in parallel
    # Health check continuously monitors streaming status
    streaming_health_check >> send_notification

    # Notification also waits for batch completion
    process_batch >> send_notification

    # Final notification waits for both:
    # - Batch completion (directly)
    # - Health check confirmation (indirectly)
    send_notification << [process_batch, streaming_health_check]