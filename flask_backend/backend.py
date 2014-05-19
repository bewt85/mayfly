#!/usr/bin/env python

from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, I am the backend!' 

if __name__ == '__main__':
    app.run(port=5001)
