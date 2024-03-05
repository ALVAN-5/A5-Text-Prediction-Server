from gevent.pywsgi import WSGIServer
import os


def run(app):
    if os.environ['A5TPS_ENV'] == 'DEV':
        # Development
        # app.run(host="192.168.0.2", debug=True)
        app.run(host="localhost", debug=True)
    elif os.environ['A5TPS_ENV'] == 'PROD':
        # Production
        http_server = WSGIServer((os.environ['A5TPS_HOST_IP'], int(os.environ['A5TPS_HOST_PORT'])), app)
        http_server.serve_forever()
