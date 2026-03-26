from flask import Flask
import requests

app = Flask(__name__)
@app.route("/pay")
def pay():
    response = requests.get("http://notification-service/notify")
    return {
        "payment": "processed",
        "notification": response.json()
    }

@app.route("/health")
def health():
    return {"status": "payment service healthy"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)