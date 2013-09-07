"SELECT *, CASE WHEN macaddress = "+"'"+macaddress+"'"+" THEN true ELSE false END as is_visited FROM user_location a, location b where a.location_id = b.id;"

(select * from location a left join user_location b ON b.location_id = a.id where b.macaddress= 'CC785FD0E6DB' OR b.macaddress IS NULL);
