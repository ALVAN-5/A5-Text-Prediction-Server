import atexit
from flask import Flask, Response, request
from prediction import predictor
import requests
import json
import os

app = Flask(__name__)

ENVIRONMENT = os.environ['A5TPS_ENV'] or 'DEV'

# THIS SHOULD BE EMPTY BEFORE MERGING
DEV_IP_OVERRIDE: list[str] = ["192.168.1.155"]

res = requests.get(
    'https://raw.githubusercontent.com/ALVAN-5/A5-Static-Content/master/backend/text-prediction-server-allowed-ips.json'
)
allowed_ips = json.loads(res.text)

res = requests.get('https://raw.githubusercontent.com/ALVAN-5/A5-Static-Content/master/backend/intents.json')
with open('intents.json', 'w') as f:
    f.write(res.text)
pd = predictor.Predictor('intents.json')


def on_exit():
    os.remove('intents.json')


atexit.register(on_exit)


def train():
    global pd
    res = requests.get('https://raw.githubusercontent.com/ALVAN-5/A5-Static-Content/master/backend/intents.json')
    with open('intents.json', 'w') as f:
        f.write(res.text)
    pd = predictor.Predictor('intents.json')
    return res.text


@app.before_request
def before_request():
    print("remote_addr", request.remote_addr)
    if request.remote_addr not in allowed_ips[ENVIRONMENT.lower()] + DEV_IP_OVERRIDE:
        return Response(status=401)


@app.route('/retrain', methods=['POST'])
def retrain():
    try:
        return train()
    except Exception:
        return Response(
            "Internal Server Error",
            status=500,
        )


@app.route('/update-ips', methods=['POST'])
def update_ips():
    global allowed_ips
    try:
        res = requests.get(
            'https://raw.githubusercontent.com/ALVAN-5/A5-Static-Content/master/backend/' +
            'text-prediction-server-allowed-ips.json'
        )
        allowed_ips = json.loads(res.text)
    except Exception:
        return Response(
            "Internal Server Error",
            status=500,
        )


@app.route('/query')
def query():
    if request.args.get('query') is None:
        return Response(
            "Bad request",
            400
        )
    try:
        if pd is None:
            raise Exception
        output = pd.query(str(request.args.get('query')))
        query_response = {
            "tag": output[0],
            "context_set": output[1],
            "response_code": output[2],
            "flags": output[3]
        }
        return Response(
            json.dumps(query_response),
            status=200
        )
    except Exception:
        return Response(
            "Internal Server Error",
            status=500,
        )


if __name__ == '__main__':
    # app.run(host="192.168.1.155")
    app.run(host="localhost")
