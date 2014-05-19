#!/usr/bin/env python

from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/')
def hello_world():
    message={'message': 'Hello, I am the backend!'}
    return jsonify(**message)

if __name__ == '__main__':
    app.run(port=5001)
