from app import create_app
import os

app = create_app()

# This block only runs when executing directly (not via Gunicorn)
if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('FLASK_ENV') == 'development'
    # Only use Flask dev server for local development
    app.run(host='0.0.0.0', port=port, debug=debug)