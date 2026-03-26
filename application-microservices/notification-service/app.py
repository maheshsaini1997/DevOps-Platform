from flask import Flask

app = Flask(__name__)
@app.route("/notify")
def notify():
    return {"notification": "sent"}

@app.route("/health")
def health():
    return {"status": "notification service healthy"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002)