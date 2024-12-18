from flask import request, jsonify, Flask
import db as dbm

app = Flask(__name__)



#401 errato
#200 corretto

@app.route("/api/login", methods=["POST"])
def login():
    db = dbm.Database()
    data = request.get_json()
    
    if 'username' not in data or 'password' not in data:
        return jsonify({"status": "error"}), 401
    
    username = data['username']
    password = data['password']
    
    if(db.login(username, password)):
        token = db.getToken(username)
        return jsonify({"token": token}), 200
    
    return jsonify({"status": "error"}), 401
    


@app.route("/api/materie", methods=["GET"])
def getMaterie():
    db = dbm.Database()
    print(request.headers)
    if 'token' not in request.headers:
        return jsonify({"status": "error"}), 401
    token = request.headers['token']
    if(db.checkToken(token)!=None):
        materie = db.getMaterie(token)
        return jsonify({"materie": materie}), 200
    return jsonify({"status": "error"}), 401



if(__name__ == "__main__"):
    app.run(debug=True)