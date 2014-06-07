#!/usr/bin/env python

from flask import Flask, jsonify
import flask
app = Flask(__name__)

VERSION='0.0.2'

@app.route('/')
def hello_world():
    mayfly_header = flask.request.headers.get('x-mayfly')
    backend_message = "This request used version %s of the backend" % VERSION
    message={'message': backend_message} 
    return jsonify(**message)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
