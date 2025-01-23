import mysql.connector
import os
import hashlib
import readerSettings

class Database:
    def __init__(self):
        rs = readerSettings.Setting()
        print(rs)
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
        query = "insert into user(username, password) values(%s, %s)"
        try:
            self.cursor.execute(query, (username, password))
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
        query = "select token from device where idU = (select id from user where username = %s)"
        self.cursor.execute(query, (username,))
        result = self.cursor.fetchall()
        if(len(result) == 1):
            self.close()
            return result[0]['token']
        else:
            token = hashlib.md5(os.urandom(32)).hexdigest()
            query = "insert into device(token, idU) values(%s, (select id from user where username = %s))"
            self.cursor.execute(query, (token, username))
            self.connection.commit()
            self.close()
            return token
        
    def checkToken(self, token):
        query = "select * from device where token = %s"
        self.cursor.execute(query, (token,))
        result = self.cursor.fetchall()
        self.close()
        if(len(result) == 1):
            return result[0]
        return None


    def getMaterie(self, token):
        q = "select m.nome, m.id from materie m, device d where d.idU = m.idU and d.token = %s"
        self.cursor.execute(q, (token,))
        result = self.cursor.fetchall()
        self.close()
        return result
    
    
    def addMateria(self, token, materia):
        query = "insert into materie(nome, idU) values(%s, (select idU from device where token = %s))"
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
            query = "select v.voto, v.data, v.descr, p.nome, p.cognome, m.nome materia from voti v, professori p, device d, materie m where v.idP = p.id and v.idM = m.id and v.idU = d.idU and d.token = %s order by v.data desc"
            self.cursor.execute(query, (token,))
        else:
            query = "select v.voto, v.data, v.desc, p.nome, p.cognome, m.nome materia from voti v, professori p, device d, materie m where v.idP = p.id and v.idM = m.id and v.idU = d.idU and d.token = %s and m.nome = %s order by v.data desc"
            self.cursor.execute(query, (token, materia))
        result = self.cursor.fetchall()
        self.close()
        return result

    def addVoto(self, token, voto, data, descr, idProf, idMateria):
        query = "insert into voti(voto, data, descr, idP, idU, idM) values(%s, %s, %s, %s, (select idU from device where token = %s), %s)"
        try:
            self.cursor.execute(query, (voto, data, descr, idProf, token, idMateria))
            self.connection.commit()
            self.close()
            return True
        except:
            self.close()
            return False
        
    def getProfessori(self, token):
        query = "select p.nome, p.cognome, m.nome materia from professori p, materie m where p.idM = m.id and m.idU = (select idU from device where token = %s)"
        self.cursor.execute(query, (token,))
        result = self.cursor.fetchall()
        self.close()
        return result

    def addProfessore(self, token, nome, cognome, idM):
        query = "insert into professori(nome, cognome, idM, idU) values(%s, %s, %s, (select idU from device where token = %s))"
        try:
            self.cursor.execute(query, (nome, cognome, idM, token))
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

create table user(
    id int primary key auto_increment,
    username varchar(255) not null unique,
    password varchar(255) not null
)

create table materie(
    id int primary key auto_increment,
    nome varchar(255) not null,
    idU int not null,
    foreign key (idU) references user(id),
    unique (nome, idU)
)

create table professori(
    id int primary key auto_increment,
    nome varchar(255) not null,
    cognome varchar(255) not null,
    idM int not null,
    idU int not null,
    foreign key (idM) references materie(id),
    foreign key (idU) references user(id),
    unique (idM, idU, nome, cognome)
)

create table voti(
    id int primary key auto_increment,
    voto float not null check(voto >= 0 and voto <= 10),
    data date not null,
    desc varchar(255),
    idP int not null,
    idU int not null,
    idM int not null,
    foreign key (idP) references professori(id),
    foreign key (idU) references user(id),
    foreign key (idM) references materie(id)
)

create table device(
    id int primary key auto_increment,
    token varchar(255) not null unique,
    idU int not null,
    foreign key (idU) references user(id)
)



"""
