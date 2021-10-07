from flask import Flask, make_response, request, render_template
from random import random
import jwt
import datetime

SECRET_KEY = "jasnfj"
flask_app = Flask(__name__)

def verify_token(token):
    if token:
        decoded_token = jwt.decode(token, SECRET_KEY, "HS256")
        print(decoded_token)
    # Check wether the information in decoded_token is correct or not

        return True # if the information is correct, otherwise return False
    else:
        return False

@flask_app.route('/')
def index_page():
    print(request.cookies)
    isUserLoggedIn = False
    if 'token' in request.cookies:
        isUserLoggedIn = verify_token(request.cookies['token'])

    if isUserLoggedIn: # 'user_id' in request.cookies
        return "Welcome back to the website"
    else:
        user_id = random()
        print(f"User ID: {user_id}")
        resp = make_response("This is the index page of a Secure REST API")
        resp.set_cookie('user_id', str(user_id))
        return resp

@flask_app.route('/help')
def help_page():
    return "This is the help page"

@flask_app.route('/login')
def login_page():
    return render_template('login.html')

def create_token(username, password):
    validity = datetime.datetime.utcnow() + datetime.timedelta(days = 15)
    token = jwt.encode({'user_id': 123154, 'username': username, 'expiry': str(validity)}, SECRET_KEY, "HS256")
    return token

@flask_app.route('/authenticate', methods = ['POST'])
def authenticate_users():
    data = request.form
    username = data['username']
    password = data['password']
    print(f"Username: {username}")
    print(f"Password: {password}")

    # check whether the username and password are correct
    user_token = create_token(username, password)

    token = create_token(username, password)
    resp = make_response("Logged In Successfully")
    #resp.set_cookie("loggedIn", "True")
    resp.set_cookie('token', user_token)
    return resp

@flask_app.route('/calculator', methods = ['GET', 'POST'])
def calculator():
    if request.method == 'GET':
        return render_template('calculator.html')
    elif request.method == 'POST':
        data = request.form
        first_number = int(data['first_number'])
        second_number = int(data['second_number'])
        addition = first_number + second_number
        subtraction = first_number - second_number
        division = first_number / second_number
        multiplication = first_number * second_number

        kwargs = {
            'post': True,
            'addition': addition,
            'subtraction': subtraction,
            'division': division,
            'multiplication': multiplication
        }
        return render_template('calculator.html', **kwargs)

if __name__ == '__main__':
    print("this is a secure REST API server")
    #flask_app.run(debug = True, ssl_context = 'adhoc')
    flask_app.run(debug = True, ssl_context = ('cert/cert.pem', 'cert/key.pem'), host = "0.0.0.0")
