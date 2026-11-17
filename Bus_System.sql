CREATE TABLE "user" (
    user_id       SERIAL PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    mid_name      VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    birth_date    DATE NOT NULL CHECK (birth_date > DATE '1900-01-01'),
    user_location VARCHAR(100)
);

CREATE TABLE user_phone_no (
    user_id  INT NOT NULL
             REFERENCES "user"(user_id) ON DELETE CASCADE,
    phone_no VARCHAR(20) NOT NULL,
    PRIMARY KEY (user_id, phone_no)
);

CREATE TABLE bus (
    bus_id SERIAL PRIMARY KEY,
    type   VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL
           CHECK (status IN ('Active', 'Maintenance', 'Retired'))
);

CREATE TABLE seat (
    bus_id    INT NOT NULL
              REFERENCES bus(bus_id) ON DELETE CASCADE,
    seat_id   INT NOT NULL CHECK (seat_id > 0),
    seat_type VARCHAR(20) NOT NULL
              CHECK (seat_type IN ('Window', 'Aisle')),
    PRIMARY KEY (bus_id, seat_id)
);

CREATE TABLE station (
    station_id       SERIAL PRIMARY KEY,
    station_location VARCHAR(100) NOT NULL,
    name             VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE trip (
    trip_id              SERIAL PRIMARY KEY,
    bus_id               INT NOT NULL REFERENCES bus(bus_id),
    origin_location      INT NOT NULL REFERENCES station(station_id),
    destination_location INT NOT NULL REFERENCES station(station_id),
    start_date_time      TIMESTAMP NOT NULL,
    end_date_time        TIMESTAMP NOT NULL,
    price                NUMERIC(8,2) NOT NULL CHECK (price >= 0),
    CHECK (end_date_time > start_date_time),
    CHECK (origin_location <> destination_location),
    UNIQUE (trip_id, bus_id) 
);

CREATE TABLE stops_at (
    trip_id    INT NOT NULL
               REFERENCES trip(trip_id) ON DELETE CASCADE,
    station_id INT NOT NULL
               REFERENCES station(station_id) ON DELETE CASCADE,
    stop_order INT NOT NULL CHECK (stop_order > 0),
    PRIMARY KEY (trip_id, station_id),
    UNIQUE (trip_id, stop_order)
);

CREATE TABLE booking (
    booking_id SERIAL PRIMARY KEY,
    status     VARCHAR(20) NOT NULL DEFAULT 'Confirmed'
               CHECK (status IN ('Confirmed', 'Pending', 'Cancelled')),
    user_id    INT REFERENCES "user"(user_id) ON DELETE SET NULL,
    seat_id    INT NOT NULL,
    bus_id     INT NOT NULL,
    trip_id    INT NOT NULL,

    FOREIGN KEY (bus_id, seat_id)
        REFERENCES seat(bus_id, seat_id),

    FOREIGN KEY (trip_id, bus_id)
        REFERENCES trip(trip_id, bus_id) ON DELETE CASCADE
);




CREATE UNIQUE INDEX uq_booking_active_seat
    ON booking (trip_id, seat_id, bus_id)
    WHERE status <> 'Cancelled';