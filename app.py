import logging
# from flask import Flask
from flask import Flask, jsonify

app = Flask(__name__)


@app.get('/')
def root_get_endpoint():
    app.logger.debug('Test debugging output')

    # return "Hello, World!"
    return jsonify({"Hello": "World!"}), 200


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=int("8000"), debug=True)
