import atexit
from flask import Flask, Response, request
from prediction import predictor
import requests
import json
import os
import runner
import punkt_setup

app = Flask(__name__)

ENVIRONMENT = os.environ['A5TPS_ENV'] or 'DEV'

# THIS SHOULD BE EMPTY BEFORE MERGING
DEV_IP_OVERRIDE: list[str] = ['172.23.0.1']

res = requests.get(os.environ['A5TPS_ALLOWED_IPS_URL'])
allowed_ips = json.loads(res.text)

res = requests.get(os.environ['A5TPS_INTENTS_URL'])
with open('intents.json', 'w') as f:
    f.write(res.text)
pd = predictor.Predictor('intents.json')

try:
    pd.query('this is a test')
except LookupError:
    punkt_setup.setup()


def on_exit():
    os.remove('intents.json')


atexit.register(on_exit)


def train():
    global pd
    res = requests.get(os.environ['A5TPS_INTENTS_URL'])
    with open('intents.json', 'w') as f:
        f.write(res.text)
    pd = predictor.Predictor('intents.json')
    return res.text


@app.before_request
def before_request():
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
        res = requests.get(os.environ['A5TPS_ALLOWED_IPS_URL'])
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
    # try:
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
    # except Exception:
    #     return Response(
    #         "Internal Server Error",
    #         status=500,
    #     )


@app.route('/health/', methods=['GET'])
@app.route('/health', methods=['GET'])
def health():
    '''
    return 200
    '''
    return Response(
        json.dumps({'health': 'ok'}),
        status=200
    ) 

if __name__ == '__main__':
    runner.run(app)
