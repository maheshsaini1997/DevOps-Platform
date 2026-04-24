from flask import Flask
import requests


app = Flask(__name__)

@app.route("/")
def home():
    return "User Service Running"

@app.route("/pay")
def call_payment():
    response = requests.get("http://payment-service/pay")
    return response.json()

@app.route("/health")
def health():
    return {"status": "user service healthy"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)