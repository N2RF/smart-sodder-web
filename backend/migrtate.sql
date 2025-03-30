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
    number SERIAL NOT NULL,
    lab_id INT  NOT NULL,
    status boolean  NOT NULL,
    wats_per_hour INT  NOT NULL,
    hours_on INT  NOT NULL,
    minutes_on INT  NOT NULL,
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
