DROP TABLE IF EXISTS  devices cascade ;
DROP TABLE IF EXISTS  benches cascade ;
DROP TABLE IF EXISTS  lab cascade ;
DROP TABLE IF EXISTS  labs cascade ;
DROP TABLE IF EXISTS history cascade ;

CREATE TABLE labs (
     id SERIAL,
     lab_name TEXT NOT NULL,
     number_of_boards INT NOT NULL,
     PRIMARY KEY (id)
);

CREATE TABLE devices (
    mac_address TEXT,
    number INT,
    lab_id INT,
    status boolean,
    wats_per_hour INT,
    hours_on INT,
    minutes_on INT,
    PRIMARY KEY (mac_address),
    FOREIGN KEY (lab_id) REFERENCES labs(id)
);


CREATE TABLE history (
    Id SERIAL PRIMARY KEY,
    mac_address text,
    Status boolean,
    Time TEXT,
    FOREIGN KEY (mac_address) REFERENCES devices(mac_address)
);
