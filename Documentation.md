# Documentation

## Bus Trip Booking System:&#32;

DBMS Project, Phase 1

## 1. Overview

Passengers book a seat on a bus trip between stations. The database stores users, buses, seats, stations, trips, stops and bookings.

## 2. Business Rules

1. A booking is for one seat on one trip.
2. The seat must exist and must belong to the bus that runs the trip.
3. A seat has only one active booking per trip. Cancelling a booking frees the seat.
4. A trip ends after it starts, and its origin and destination are different.
5. Price cannot be negative. The amount paid is the trip price, so it is not stored.
6. Age is calculated from Birth\_Date and is not stored.

## 3. Entities and Attributes

| Entity | Attributes |
| --- | --- |
| User | User\_No (key), Name (composite: First, Mid, Last), Birth\_Date, Age (derived), Phone\_No (multivalued), User\_Location (optional) |
| Bus | Bus\_No (key), Type, Status |
| Seat (weak) | Seat\_No (partial key), Seat\_Type |
| Station | Station\_No (key), Station\_Location, Name |
| Trip | Trip\_No (key), Date\_Time (composite: Start, End), Price |
| Booking | Booking\_No (key), Status |

- **Seat is weak** because seat numbers repeat on every bus. A seat is identified by its bus and its seat number.
- **Booking is its own entity,** so a user can book the same trip again, for example, after cancelling or even for another partner.

## 4. Relationships

| Relationship | Entities | Degree | Why it is made this way |
| --- | --- | --- | --- |
| ticket | User - Booking | 1-M | A user can book many times, but each booking has one owner, so User\_No goes in BOOKING. |
| booking\_trip | Trip - Booking | 1-M | A trip is booked once per seat, and each booking is for one trip, so Trip\_No goes in BOOKING. |
| seat\_on\_booking | Seat - Booking | 1-M | A seat is reused on many trips, so it appears in many bookings, but each booking holds one seat. |
| seats\_in\_bus (identifying) | Bus - Seat | 1-M | A seat exists only inside one bus and its number repeats on other buses, so it is identified by its bus. |
| bus\_on\_trip | Bus - Trip | 1-M | One bus runs many trips over time, but a trip uses one bus, so Bus\_No goes in TRIP. |
| origin | Station - Trip | 1-M | A trip starts at exactly one station, and a station can start many trips. |
| destination | Station - Trip | 1-M | Same reason for where a trip ends. It is separate from origin because the two roles differ. |
| stops\_at | Trip - Station | M-N | A trip makes many stops and a station is a stop on many trips, so a junction table is needed. Stop\_Order gives the stop sequence. |

There are no 1-1 relationships.

## 5. Mapping to the Schema

- Each entity becomes a table. Composite attributes are split into their parts. Age is not stored.
- Seat becomes SEAT with key (Bus\_No, Seat\_No).
- Each 1-M relationship adds a foreign key to the many side.
- stops\_at becomes the table STOPS\_AT with key (Trip\_No, Station\_No).
- Phone\_No becomes the table USER\_PHONE\_NO with key (User\_No, Phone\_No).

## 6. Seat Rules in SQL

- **Foreign key (Bus\_No, Seat\_No) to SEAT:** the seat must exist.
- **Foreign key (Trip\_No, Bus\_No) to TRIP:** the seat's bus must be the trip's bus. This needs UNIQUE (Trip\_No, Bus\_No) on TRIP. BOOKING keeps one Bus\_No column for both keys, a deliberate redundancy.
- **Unique index on (Trip\_No, Seat\_No, Bus\_No) where Status is not Cancelled:** one active booking per seat per trip, and cancelled seats can be rebooked.

## 7. Constraints

| Table | Constraints |
| --- | --- |
| USER | NOT NULL on names and birth date. CHECK birth date after 1900. User\_Location can be NULL. |
| USER\_PHONE\_NO | PK (User\_No, Phone\_No). |
| BUS | CHECK Status is Active, Maintenance or Retired. |
| SEAT | CHECK Seat\_No > 0. CHECK Seat\_Type is Window or Aisle. |
| STATION | UNIQUE Name. |
| TRIP | CHECK end after start. CHECK origin differs from destination. CHECK Price >= 0. UNIQUE (Trip\_No, Bus\_No). |
| STOPS\_AT | CHECK Stop\_Order > 0. UNIQUE (Trip\_No, Stop\_Order). |
| BOOKING | CHECK Status is Confirmed, Pending or Cancelled. DEFAULT Confirmed. User\_No can be NULL. |

**Foreign key actions**

- ON DELETE CASCADE: phone numbers of a user, seats of a bus, stops of a trip or station, bookings of a trip.
- ON DELETE SET NULL: BOOKING.User\_No, so booking history stays when a user is deleted. The IT Department always says: Do not delete any data.
- No action (restrict): a seat with bookings, a bus, or a station used by a trip.

## 8. Assumptions

- A booking has one seat. A passenger who needs more seats makes more bookings.
- stops\_at holds only intermediate stops. Origin and destination are stored in TRIP.
