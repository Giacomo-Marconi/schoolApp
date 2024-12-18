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
        q = "select m.name, m.id from materie m, device d where d.idU = m.idU and d.token = %s"
        self.cursor.execute(q, (token,))
        result = self.cursor.fetchall()
        self.close()
        return result
    




def main():
    db = Database()



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
