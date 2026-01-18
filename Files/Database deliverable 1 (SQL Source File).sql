 -- 1.1.	
CREATE TABLE municipality (
    province_code VARCHAR2(10) PRIMARY KEY,
    province_nme VARCHAR2(50) NOT NULL
);

CREATE TABLE municipality (
    municipality_code VARCHAR2(10) PRIMARY KEY,
    municipality_name VARCHAR(50) NOT NULL,
    average_population NUMBER,
    province_code VARCHAR2(10),
    FOREIGN KEY (province_code) REFERENCES province(province_code)
);

CREATE TABLE facility (
    facility_id VARCHAR2(10) PRIMARY KEY,
    facility_name VARCHAR2(100) NOT NULL,
    capacity NUMBER,
    address VARCHAR2(100),
    municipality_code VARCHAR2(10),
    FOREIGN KEY (municipality_code) REFERENCES municipality(municipality_code)
);

CREATE TABLE room (
    room_number VARCHAR2(10) PRIMARY KEY,
    description VARCHAR2(50),
    facility_id VARCHAR2(10),
    FOREIGN KEY (facility_id) REFERENCES facility(facility_id)
);

CREATE TABLE activity (
    actRef VARCHAR2(10) PRIMARY KEY,
    activityName VARCHAR2(50)
);

CREATE TABLE uses (
    facility_id VARCHAR2(10),
    actRef VARCHAR2(10),
    useDate DATE,
    PRIMARY KEY (facility_id, actRef, useDate),
    FOREIGN KEY (facility_id) REFERENCES facility(facility_id),
    FOREIGN KEY (actRef) REFERENCES activity(actRef)


 -- 1.2.
CREATE SEQUENCE seq_province_id
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

CREATE SEQUENCE seq_municipality_id
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

CREATE SEQUENCE seq_facility_id
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

CREATE SEQUENCE seq_room_id
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

CREATE SEQUENCE seq_activity_id
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;
  

 -- 1.3.	
INSERT INTO province (province_code, province_name)
VALUES ('P' || seq_province_id.NEXTVAL, 'KwaZulu-Natal');

INSERT INTO province (province_code, province_name)
VALUES ('P' || seq_province_id.NEXTVAL, 'Limpopo');

INSERT INTO municipality (municipality_code, municipality_name, average_population, province_code)
VALUES ('M' || seq_municipality_id.NEXTVAL, 'Durban', 3200000, 'P1');

INSERT INTO municipality (municipality_code, municipality_name, average_population, province_code)
VALUES ('M' || seq_municipality_id.NEXTVAL, 'Venda', 1200000, 'P2');

INSERT INTO facility (facility_id, facility_name, capacity, address, municipality_code)
VALUES ('F' || seq_facility_id.NEXTVAL, 'Durban Cultural Centre', 200, 'Bellair Road 25', 'M1');

INSERT INTO facility (facility_id, facility_name, capacity, address, municipality_code)
VALUES ('F' || seq_facility_id.NEXTVAL, 'Vhavenda Art Museum', 120, 'Mudau Street 112', 'M2');

INSERT INTO room (room_number, description, facility_id)
VALUES ('R' || seq_room_id.NEXTVAL, 'Theatre Room', 'F1');

INSERT INTO room (room_number, description, facility_id)
VALUES ('R' || seq_room_id.NEXTVAL, 'Art Hall', 'F2');

INSERT INTO activity (actRef, activityName)
VALUES ('A' || seq_activity_id.NEXTVAL, 'Isizulu Dance Show');

INSERT INTO activity (actRef, activityName)
VALUES ('A' || seq_activity_id.NEXTVAL, 'Venda Art Exhibition');

INSERT INTO uses (facility_id, actRef, useDate)
VALUES ('F1', 'A1', TO_DATE('30-JUN-2025', 'DD-MON-YYYY'));

INSERT INTO uses (facility_id, actRef, useDate)
VALUES ('F2', 'A2', TO_DATE('2-JUN-2025', 'DD-MON-YYYY'));

 -- 1.4.	
SELECT COUNT(*) AS municipalities_without_music
FROM municipality m
WHERE NOT EXISTS (
    SELECT 1
    FROM facility f
    JOIN uses u ON f.facility_id = u.facility_id
    JOIN activity a ON u.ACTREF = a.actRef
    WHERE f.municipality_code = m.municipality_code
    AND LOWER(a.activityName) LIKE '%music%'
);

 -- 1.5.	
SELECT province_name
FROM PROVINCE
WHERE province_code IN (
    SELECT DISTINCT PROVINCE_CODE
    FROM MUNICIPALITY
    WHERE average_population >= 4000000
);
(Editor, 2025)

 -- 1.6.	
CREATE PROCEDURE province_Capacity_Utilisation_procedure IS
BEGIN
  DBMS_OUTPUT.PUT_LINE(RPAD('Province', 20) ||
                       RPAD('Facilities', 12) ||
                       RPAD('Total Capacity', 18) ||
                       RPAD('Total Activities', 18) ||
                       RPAD('Utilisation (%)', 18));
  DBMS_OUTPUT.PUT_LINE(RPAD('-', 80, '-'));

  FOR rec IN (
    SELECT 
      p.province_name,
      COUNT(DISTINCT f.facility_id) AS num_facilities,
      SUM(f.capacity) AS total_capacity,
      COUNT(u.actRef) AS total_activities,
      ROUND(
        CASE 
          WHEN SUM(f.capacity) = 0 THEN 0
          ELSE (COUNT(u.actRef) / SUM(f.capacity)) * 100
        END, 2
      ) AS utilisation_percentage
    FROM province p
    JOIN municipality m ON p.province_code = m.province_code
    JOIN facility f ON m.municipality_code = f.municipality_code
    LEFT JOIN uses u ON f.facility_id = u.facility_id
    GROUP BY p.province_name
    ORDER BY utilisation_percentage DESC
  ) LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(rec.province_name, 20) ||
                         RPAD(rec.num_facilities, 12) ||
                         RPAD(rec.total_capacity, 18) ||
                         RPAD(rec.total_activities, 18) ||
                         RPAD(rec.utilisation_percentage || '%', 18));
  END LOOP;
END;
/
