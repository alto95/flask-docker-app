def test_homepage():
    from app import app
    with app.test_client() as client:
        response = client.get('/')
        assert response.status_code == 200
        assert b"Hello from your Dockerized Flask app" in response.data

def test_database_connection():
    from app import app
    with app.test_client() as client:
        response = client.get('/db')
        assert response.status_code == 200
        assert b"Connected to PostgreSQL!" in response.data or b"Database connection failed" in response.data
