import json

class Setting:
    def __init__(self):        
        with open("./setting.json", "r") as f:
            data = json.load(f)
            self.host = data['db']["host"]
            self.database = data['db']["database"]
            self.username = data['db']["username"]
            self.password = data['db']["password"]
            self.port = data['server']["port"]

    def __repr__(self):
        return f"host: {self.host}, database: {self.database}, username: {self.username}, password: {self.password}, port: {self.port}"