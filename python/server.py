#!/usr/bin/python
# -*- coding: utf-8 -*-

from itty import get, run_itty, Response
import requests
import json
import MySQLdb as mdb

con = mdb.connect('localhost', 'root', 'yeppt2013!', 'spacetime', use_unicode = True);



@get('/user')
def index(request):
    
    cur = con.cursor()
    cur.execute("SELECT * FROM user")
    
    rows = cur.fetchall()
    
    files = []
    for row in rows:
        files.append(row)
    return Response(json.dumps({'files':files}),content_type='application/json')

@get('/location')
def index(request):
    macaddress = request.GET['macaddress']    
    cur = con.cursor()
    #cur.execute("select * from location")
    #cur.execute("SELECT *, CASE WHEN macaddress = "+"'"+macaddress+"'"+" THEN true ELSE false END as is_visited FROM user_location;")
    cur.execute( "select z.id, z.name, case when macaddress IS NULL THEN false else true end as is_visited from (select * from location a left outer join user_location b ON b.location_id = a.id AND b.macaddress = '" + macaddress + "')z")
    #SELECT *, CASE WHEN macaddress = "CC785FD0E6DB" THEN true ELSE false END as is_visited FROM user_location a, location b where a.location_id = b.id;
    rows = cur.fetchall()
    
    loc = []
    for row in rows:
        loc.append({"id" : row[0], "description" : row[1], "is_visited":row[2]})
        #loc.append({"files" : row})

    return Response(json.dumps({'location':loc}),content_type='application/json')

@get('/files/')

def index(request):
    macaddress = request.GET['macaddress']    
    cur = con.cursor()
    #cur.execute("SELECT z.*, CASE WHEN macaddress IS NULL THEN false ELSE true END as is_visited FROM (select * from location a left join user_location b ON b.location_id = a.id where b.macaddress= '" + macaddress + "' OR b.macaddress IS NULL)z;")
    cur.execute("SELECT name, id_location FROM file")
    

    rows = cur.fetchall()
    
    files = []
    for row in rows:
        files.append({"filename":row[0], "location":row[1]})
    return Response(json.dumps({'filename':files}),content_type='application/json')


@get('/upload/')
def index(request):
    filename = request.GET['filename']
    location = request.GET['location']

    cur = con.cursor()
    sql = """INSERT INTO file(name, path, id_location) VALUES ("""+"'"+ filename+ "'" +""","""+"'"+ filename+ "'" +""","""+location+""")"""
    
    with con:
    
        cur = con.cursor()
        cur.execute(sql)

    return Response("...")



@get('/checkin/')
def index(request):
    macaddress = request.GET['macaddress']
    location = request.GET['location']
    
    cur = con.cursor()
    sql_insert = """INSERT IGNORE INTO user_location(macaddress, location_id) VALUES ("""+"'"+ macaddress+ "'" +""","""+location+""")"""
    sql_lookup = "Select * from user_location where macaddress = " + "'" + macaddress + "'" + " and location_id =" + location    
    sql_location = "Select name from location where id =" + location    
    with con:
        cur.execute(sql_lookup)
        if len(cur.fetchall())==0:
            cur.execute(sql_insert)
            cur.execute(sql_location)
            rows = cur.fetchall()
    
            files = []
            for row in rows:
                files.append(row[0])

            #url = 'http://sms77.de/gateway/?u=eVoDesign&p=19058c741457f13eb397607f6d4d56d5&to=00491608071336&text=Sie wurden fuer die Location+' + row[0] + '+freigeschaltet&type=quality&from=spacetime'
            url = 'https://tropo.developergarden.com/api/sessions?action=create&token=4e427865446b4f6f77466e4b4a786d61536b626d57556b625a4472414664424950614671495453614a494c71&msg=Sie wurden fuer die Location+' + row[0] + '+freigeschaltet HIER FOLGT CUSTOM URL&number=4917699664428'
            print url
            requests.get(url)
            #print test.text
            #print row[0]
            
            return Response("SMS VERSENDEN")
    return Response("...")

run_itty(host = '0.0.0.0') 













