#!/usr/bin/env python

from flask import Flask, jsonify
import flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    mayfly_header = flask.request.headers.get('x-mayfly')
    message_text = 'Hello, I am the backend'
    if mayfly_header:
        message_text += " in the %s environment" % mayfly_header
    message={'message': message_text} 
    return jsonify(**message)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
