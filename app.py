from flask import Flask
import os
import psycopg2
import logging

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.WARNING)

@app.route('/')
def hello():
    app.logger.info("Homepage was accessed.")
    return "Hello from your Dockerized Flask app! \n dupa ce s-a creat DB si s-a adaugat frameworkul"

@app.route('/db')
def test_db():
    try:
        conn = psycopg2.connect(
            host=os.getenv("DB_HOST"),
            port=os.getenv("DB_PORT"),
            database=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD")
        )
        app.logger.info("Database connection successful.")
        cur = conn.cursor()
        cur.execute("SELECT version();")
        version = cur.fetchone()[0]
        cur.close()
        conn.close()
        return f"Connected to PostgreSQL!<br><br>Version: {version}"
    except Exception as e:
        app.logger.error(f"Database connection failed: {e}")
        return f"Database connection failed: {e}"

@app.route('/warn')
def warn():
    app.logger.warning("This is a test warning.")
    return "Warning was logged!"


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
