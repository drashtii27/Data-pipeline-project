FROM apache/airflow:2.9.1

# Install dependencies
USER airflow
RUN pip install statsmodels pandas numpy

# Copy requirements file
COPY --chown=airflow:root requirements.txt /opt/airflow/
RUN pip install -r /opt/airflow/requirements.txt