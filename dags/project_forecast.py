# -*- coding: utf-8 -*-
"""project_forecast.ipynb

Automatically generated by Colab.

Original file is located at
    https://colab.research.google.com/drive/1CDszp6fiJGwebKCBDN4TdOUcgukl77F3
"""

from airflow import DAG
from airflow.decorators import task
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from datetime import datetime, timedelta
import pandas as pd
import logging
from statsmodels.tsa.arima.model import ARIMA

# Default DAG arguments
default_args = {
    'owner': 'Lab2',
    'start_date': datetime(2024, 11, 13),
    'retries': 0,
}

# DAG Definition
with DAG(
    dag_id='bitcoin_forecast',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False,
) as dag:

    @task
    def fetch_data():
        """Fetch historical and real-time Bitcoin data from Snowflake."""
        snowflake_hook = SnowflakeHook(snowflake_conn_id='snowflake_default')
        conn = snowflake_hook.get_conn()
        cur = conn.cursor()

        try:
            cur.execute("USE DATABASE lab2")
            cur.execute("USE SCHEMA raw_data")

            query = """
                SELECT time_close, price_close
                FROM bitcoin_historical
                UNION ALL
                SELECT time_close, price_close
                FROM bitcoin_realtime
                ORDER BY time_close
            """
            cur.execute(query)
            data = cur.fetchall()

            # Convert to DataFrame and handle timestamps
            df = pd.DataFrame(data, columns=['time_close', 'price_close'])
            df['time_close'] = pd.to_datetime(df['time_close']).dt.strftime('%Y-%m-%d %H:%M:%S')

            # Convert to records format for JSON serialization
            result = df.to_dict(orient='records')
            logging.info(f"Fetched {len(result)} records from Snowflake.")
            return result

        except Exception as e:
            logging.error(f"Error fetching data: {e}")
            raise
        finally:
            cur.close()
            conn.close()

    @task
    def generate_forecast(data):
        """Generate the next 7 days' forecast."""
        try:
            # Convert list of dictionaries back to DataFrame
            df = pd.DataFrame(data)
            df['time_close'] = pd.to_datetime(df['time_close'])
            df.set_index('time_close', inplace=True)

            # Sort data chronologically
            df = df.sort_index()

            # Fit ARIMA model
            model = ARIMA(df['price_close'], order=(5, 1, 0))
            model_fit = model.fit()

            # Generate 7-day forecast
            forecast = model_fit.get_forecast(steps=7)
            forecast_df = forecast.summary_frame(alpha=0.05)

            # Prepare forecast dates
            forecast_dates = pd.date_range(
                start=df.index[-1] + timedelta(days=1),
                periods=7,
                freq='D'
            )

            # Create forecast DataFrame with serializable dates
            result_df = pd.DataFrame({
                'time_close': forecast_dates.strftime('%Y-%m-%d %H:%M:%S'),
                'price_close': forecast_df['mean'].values,
                'lower_bound': forecast_df['mean_ci_lower'].values,
                'upper_bound': forecast_df['mean_ci_upper'].values
            })

            logging.info(f"Generated forecast: {result_df}")
            return result_df.to_dict(orient='records')

        except Exception as e:
            logging.error(f"Error generating forecast: {e}")
            raise

    @task
    def load_forecast(forecast_data):
        """Load forecast data into Snowflake."""
        if not forecast_data:
            logging.error("No forecast data to load.")
            return

        snowflake_hook = SnowflakeHook(snowflake_conn_id='snowflake_default')
        conn = snowflake_hook.get_conn()
        cur = conn.cursor()

        try:
            cur.execute("USE DATABASE lab2")
            cur.execute("USE SCHEMA analytics")

            # Create forecast table if not exists
            cur.execute("""
            CREATE TABLE IF NOT EXISTS bitcoin_forecast (
                time_close TIMESTAMP_NTZ,
                price_close FLOAT,
                lower_bound FLOAT,
                upper_bound FLOAT,
                timestamp TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP
            )
            """)

            # Insert forecast records using string format for timestamps
            insert_query = """
                INSERT INTO analytics.bitcoin_forecast (
                    time_close, price_close, lower_bound, upper_bound
                ) VALUES (TO_TIMESTAMP(%s), %s, %s, %s)
            """

            for record in forecast_data:
                values = (
                    record['time_close'],  # Already in string format from generate_forecast
                    float(record['price_close']),
                    float(record['lower_bound']),
                    float(record['upper_bound'])
                )
                cur.execute(insert_query, values)

            conn.commit()
            logging.info(f"Successfully loaded {len(forecast_data)} forecast records.")

        except Exception as e:
            conn.rollback()
            logging.error(f"Error loading forecast data: {e}")
            raise
        finally:
            cur.close()
            conn.close()

    # Define task dependencies
    data = fetch_data()
    forecast = generate_forecast(data)
    load_forecast(forecast)