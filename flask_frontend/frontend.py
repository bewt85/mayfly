#!/usr/bin/env python

import requests
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    r = requests.get('http://localhost:5001/')
    backend_message = r.json()['message']
    frontend_message = "Hello world from the frontend and %s" % backend_message 
    return frontend_message 

if __name__ == '__main__':
    app.run(port=5000)
