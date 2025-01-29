from flask import request, jsonify, Flask
import db as dbm
import flask_cors

app = Flask(__name__)
flask_cors.CORS(app)

#9d49670969b15d3bb62296fc25e3a8b1
#401 errato
#200 corretto

@app.route("/api/register", methods=["POST"])
def register():
    db = dbm.Database()
    data = request.get_json()
    print(data)
    
    if 'username' not in data or 'password' not in data:
        return jsonify({"status": "error"}), 401
    
    username = data['username']
    password = data['password']
    
    if(db.register(username, password)):
        return jsonify({"status": "ok"}), 200
    
    return jsonify({"status": "error"}), 401

@app.route("/api/login", methods=["POST"])
def login():
    db = dbm.Database()
    data = request.get_json()
    
    if 'username' not in data or 'password' not in data:
        return jsonify({"status": "error"}), 401
    
    username = data['username']
    password = data['password']
    
    if(db.login(username, password)):
        token = dbm.Database().getToken(username)
        return jsonify({"token": token}), 200
    
    return jsonify({"status": "error"}), 401

@app.route("/api/materie", methods=["GET"])
def getMaterie():
    db = dbm.Database()
    if 'token' not in request.headers:
        return jsonify({"status": "error"}), 401
    token = request.headers['token']
    if(db.checkToken(token)!=None):
        materie = dbm.Database().getMaterie(token)
        return jsonify({"materie": materie}), 200
    return jsonify({"status": "error"}), 401

@app.route("/api/materie", methods=["POST"])
def addMateria():
    db = dbm.Database()
    data = request.get_json()
    if 'token' not in request.headers or 'materia' not in data:
        return jsonify({"status": "error"}), 401
    token = request.headers['token']
    materia = data['materia']
    if(db.checkToken(token)!=None):
        if(dbm.Database().addMateria(token, materia)):
            return jsonify({"status": "ok"}), 200
    return jsonify({"status": "error"}), 401

@app.route("/api/voti", methods=["GET"])
def getVoti():
    db = dbm.Database()
    if 'token' not in request.headers:
        return jsonify({"status": "error"}), 401
    token = request.headers['token']
    if(db.checkToken(token)!=None):
        
        if('materia' in request.args):
            materia = request.args['materia']
            voti = dbm.Database().getVoti(token, materia)
            return jsonify({"voti": voti}), 200
        
        voti = dbm.Database().getVoti(token)
        return jsonify({"voti": voti}), 200
    return jsonify({"status": "error"}), 401

@app.route("/api/voti", methods=["POST"])
def addVoto():
    db = dbm.Database()
    data = request.get_json()
    if 'token' not in request.headers or 'voto' not in data or 'data' not in data or 'descr' not in data or 'idM' not in data:
        return jsonify({"status": "error"}), 401
    
    token = request.headers['token']
    voto = data['voto']
    date = data['data']
    descr = data['descr']
    #idP = data['idP']
    idM = data['idM']
    
    if(db.checkToken(token)!=None):
        if(dbm.Database().addVoto(token, voto, date, descr, idM)):
            return jsonify({"status": "ok"}), 200
    return jsonify({"status": "error"}), 401

@app.route("/api/professori", methods=["GET"])
def getProfessori():
    db = dbm.Database()
    if 'token' not in request.headers:
        return jsonify({"status": "error"}), 401
    token = request.headers['token']
    if(db.checkToken(token)!=None):
        professori = dbm.Database().getProfessori(token)
        return jsonify({"professori": professori}), 200
    return jsonify({"status": "error"}), 401

@app.route("/api/professori", methods=["POST"])
def addProfessore():
    db = dbm.Database()
    data = request.get_json()
    if 'token' not in request.headers or 'nome' not in data or 'cognome' not in data or 'idM' not in data:
        return jsonify({"status": "error"}), 401
    token = request.headers['token']
    nome = data['nome']
    cognome = data['cognome']
    idM = data['idM']
    if(db.checkToken(token)!=None):
        if(dbm.Database().addProfessore(token, nome, cognome, idM)):
            return jsonify({"status": "ok"}), 200
    return jsonify({"status": "error"}), 401





if(__name__ == "__main__"):
    app.run(debug=True, host='0.0.0.0', port=23456)