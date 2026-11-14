-- =====================================================
-- Bus Trip Booking System - PostgreSQL DDL
-- =====================================================

CREATE TABLE "user" (
    user_no       SERIAL PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    mid_name      VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    birth_date    DATE NOT NULL CHECK (birth_date > DATE '1900-01-01'),
    user_location VARCHAR(100)                      -- optional
);

CREATE TABLE user_phone_no (
    user_no  INT NOT NULL
             REFERENCES "user"(user_no) ON DELETE CASCADE,
    phone_no VARCHAR(20) NOT NULL,
    PRIMARY KEY (user_no, phone_no)
);

CREATE TABLE bus (
    bus_no SERIAL PRIMARY KEY,
    type   VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL
           CHECK (status IN ('Active', 'Maintenance', 'Retired'))
);

-- Weak entity: identified by the bus it belongs to
CREATE TABLE seat (
    bus_no    INT NOT NULL
              REFERENCES bus(bus_no) ON DELETE CASCADE,
    seat_no   INT NOT NULL CHECK (seat_no > 0),
    seat_type VARCHAR(20) NOT NULL
              CHECK (seat_type IN ('Window', 'Aisle')),
    PRIMARY KEY (bus_no, seat_no)
);

CREATE TABLE station (
    station_no       SERIAL PRIMARY KEY,
    station_location VARCHAR(100) NOT NULL,
    name             VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE trip (
    trip_no              SERIAL PRIMARY KEY,
    bus_no               INT NOT NULL REFERENCES bus(bus_no),
    origin_location      INT NOT NULL REFERENCES station(station_no),
    destination_location INT NOT NULL REFERENCES station(station_no),
    start_date_time      TIMESTAMP NOT NULL,
    end_date_time        TIMESTAMP NOT NULL,
    price                NUMERIC(8,2) NOT NULL CHECK (price >= 0),
    CHECK (end_date_time > start_date_time),
    CHECK (origin_location <> destination_location),
    UNIQUE (trip_no, bus_no)   -- target of booking's composite FK
);

-- M:N relationship between trip and station
CREATE TABLE stops_at (
    trip_no    INT NOT NULL
               REFERENCES trip(trip_no) ON DELETE CASCADE,
    station_no INT NOT NULL
               REFERENCES station(station_no) ON DELETE CASCADE,
    stop_order INT NOT NULL CHECK (stop_order > 0),
    PRIMARY KEY (trip_no, station_no),
    UNIQUE (trip_no, stop_order)
);

CREATE TABLE booking (
    booking_no SERIAL PRIMARY KEY,
    status     VARCHAR(20) NOT NULL DEFAULT 'Confirmed'
               CHECK (status IN ('Confirmed', 'Pending', 'Cancelled')),
    user_no    INT REFERENCES "user"(user_no) ON DELETE SET NULL,
    seat_no    INT NOT NULL,
    bus_no     INT NOT NULL,
    trip_no    INT NOT NULL,

    -- Rule 1: the seat must exist in the seat table
    FOREIGN KEY (bus_no, seat_no)
        REFERENCES seat(bus_no, seat_no),

    -- Rule 2: the seat must belong to the bus running the trip
    FOREIGN KEY (trip_no, bus_no)
        REFERENCES trip(trip_no, bus_no) ON DELETE CASCADE
);

-- Rule 3: a seat has only one active booking per trip;
-- cancelled bookings release the seat
CREATE UNIQUE INDEX uq_booking_active_seat
    ON booking (trip_no, seat_no, bus_no)
    WHERE status <> 'Cancelled';