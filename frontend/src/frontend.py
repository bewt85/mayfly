#!/usr/bin/env python

import requests
import flask
from flask import Flask, render_template
app = Flask(__name__)

VERSION='0.0.1'

@app.route('/')
def hello_world():
    mayfly_header = flask.request.headers.get('x-mayfly')
    frontend_message = "Hello world from the frontend (v%s)" % VERSION
    request_headers = {'x-mayfly': mayfly_header} if mayfly_header else {}
    r = requests.get('http://backend.service/', headers=request_headers)
    backend_message = r.json()['message']
    return render_template('template.html', 
                           mayfly_header=mayfly_header, 
                           frontend_message=frontend_message, 
                           backend_message=backend_message) 

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
