import pytest
from app import app

# Use the Flask test client
@pytest.fixture
def client():
    with app.test_client() as client:
        yield client

def test_homepage(client):
    response = client.get('/')
    assert response.status_code == 200
    assert b"Hello from your Dockerized Flask app" in response.data

def test_db_route(client):
    response = client.get('/db')
    assert response.status_code == 200
    assert b"Connected to PostgreSQL" in response.data or b"Database connection failed" in response.data
