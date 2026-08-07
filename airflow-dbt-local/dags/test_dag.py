from airflow.sdk import dag, task
from datetime import datetime

@dag(schedule=None, start_date=datetime(2026, 1, 1), catchup=False)
def my_first_dag():

    @task
    def step_one():
        print("primo task")

    @task
    def step_two():
        print("secondo task")

    step_one() >> step_two()

my_first_dag()
