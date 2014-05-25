#!/usr/bin/env python

import requests
import flask
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    mayfly_header = flask.request.headers.get('x-mayfly')
    request_headers = {'x-mayfly': mayfly_header} if mayfly_header else {}
    r = requests.get('http://backend.service/', headers=request_headers)
    backend_message = r.json()['message']
    frontend_message = "Hello world from the frontend and %s" % backend_message 
    return frontend_message 

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
