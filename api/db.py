import mysql.connector
import os
import hashlib
import readerSettings

class Database:
    def __init__(self):
        rs = readerSettings.Setting()
        self.connection = mysql.connector.connect(
            host=rs.host,
            user=rs.username,
            password=rs.password,
            database=rs.database
        )
        self.cursor = self.connection.cursor(dictionary=True)
    
    def close(self):
        self.cursor.close()
        self.connection.close()
        
    
    def register(self, username, password):
        query = "insert into user(username, password, token) values(%s, %s, %s)"
        token = hashlib.md5(os.urandom(32)).hexdigest()

        try:
            self.cursor.execute(query, (username, password, token))
            self.connection.commit()
            self.close()
            return True
        except:
            self.close()
            return False
        
    
    def login(self, username, password):
        query = "select * from user where username = %s and password = %s"
        self.cursor.execute(query, (username, password))
        result = self.cursor.fetchall()
        self.close()
        if(len(result) == 1):
            return True
        return False
    
    def getToken(self, username):
        query = "select token from user where username = %s"
        self.cursor.execute(query, (username,))
        result = self.cursor.fetchall()
        if(len(result) == 1):
            self.close()
            return result[0]['token']
        return None
        
    def checkToken(self, token):
        query = "select * from user where token = %s"
        self.cursor.execute(query, (token,))
        result = self.cursor.fetchall()
        self.close()
        if(len(result) == 1):
            return result[0]
        return None


    def getMaterie(self, token):
        q = """
        
        select m.nome, m.id, avg(v.voto) media
        from materie m, voti v, user u
        where u.token = %s and u.id = m.idU
        group by m.nome, m.id
        """
        
        self.cursor.execute(q, (token,))
        result = self.cursor.fetchall()
        self.close()
        return result
    
    
    def addMateria(self, token, materia):
        query = "insert into materie(nome, idU) values(%s, (select id from user where token = %s))"
        try:    
            self.cursor.execute(query, (materia, token))
            self.connection.commit()
            self.close()
            return True
        except:
            self.close()
            return False
    
    
    def getVoti(self, token, materia=None):
        if(materia is None):
            query = "select v.voto, v.data, v.descr, m.nome materia from voti v, materie m, user u where v.idM = m.id and v.idU = u.id and u.token = %s order by v.data desc"
            self.cursor.execute(query, (token,))
        else:
            query = "select v.voto, v.data, v.desc, m.nome materia from voti v, user u, materie m where v.idM = m.id and v.idU = u.id and u.token = %s and m.nome = %s order by v.data desc"
            self.cursor.execute(query, (token, materia))
        result = self.cursor.fetchall()
        self.close()
        return result

    def addVoto(self, token, voto, data, descr, idMateria):
        query = "insert into voti(voto, data, descr, idU, idM) values(%s, %s, %s, (select id from user where token = %s), %s)"
        try:
            self.cursor.execute(query, (voto, data, descr, token, idMateria))
            self.connection.commit()
            self.close()
            return True
        except:
            self.close()
            return False









def main():
    Database()
    




if __name__ == "__main__":
    main()
    
    



"""
new db

create table user(
    id int primary key auto_increment,
    username varchar(255) not null unique,
    password varchar(255) not null,
    token varchar(255) not null unique
)

create table materie(
    id int primary key auto_increment,
    nome varchar(255) not null,
    idU int not null,
    foreign key (idU) references user(id),
    unique (nome, idU)
)

create table voti(
    id int primary key auto_increment,
    voto float not null check(voto >= 0 and voto <= 10),
    data date not null,
    desc varchar(255),
    idU int not null,
    idM int not null,
    foreign key (idM) references materie(id)
)

"""