from flask import Flask, _app_ctx_stack, jsonify, url_for
from flask import render_template
from flask_cors import CORS
from sqlalchemy.orm import scoped_session
import os

from simple_web_app import models
from simple_web_app.database import SessionLocal, engine

models.Base.metadata.create_all(bind=engine)

app = Flask(__name__)
app.app_context().push()

CORS(app)
app.session = scoped_session(SessionLocal, scopefunc=_app_ctx_stack.__ident_func__)

app.config.from_object(os.getenv('APP_SETTINGS',"simple_web_app.config.DevelopmentConfig"))
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False


# def create_app():
#     app = Flask(__name__)
#     return app


@app.route('/')
@app.route('/index')
def index():
    return f"See the data at <a href='{url_for('show_records')}'>records</a>"

@app.route('/records/')
def show_records():
    records = app.session.query(models.Record).all()
    return render_template('records.html', len=len(records), records=[record.to_dict() for record in  records])

@app.route('/welcome/<name>')
def hello_name(name):
    return render_template('name.html', title='Welcome', username=name)

@app.teardown_appcontext
def remove_session(*args, **kwargs):
    app.session.remove()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)