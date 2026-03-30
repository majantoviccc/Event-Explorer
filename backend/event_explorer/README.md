# EventExplorer – Project Documentation

## Overview

EventExplorer is a web application designed for managing and exploring events. It provides a RESTful API that allows users to create, retrieve, update, and delete events, as well as browse categories and cities.

The system is built using Elixir and the Phoenix Framework, following a clean and modular architecture.


## Architecture

The application follows a typical Phoenix backend structure:

* Controllers – handle HTTP requests and responses
* Contexts (Events) – contain business logic
* JSON Views – format data into JSON responses
* Router – defines API endpoints


## API Endpoints

### Events

| Method | Endpoint        | Description              |
| ------ | --------------- | ------------------------ |
| GET    | /api/events     | Retrieve all events      |
| GET    | /api/events/:id | Retrieve a single event  |
| POST   | /api/events     | Create a new event       |
| PUT    | /api/events/:id | Update an existing event |
| DELETE | /api/events/:id | Delete an event          |



### Other Resources

| Method | Endpoint        | Description             |
| ------ | --------------- | ----------------------- |
| GET    | /api/categories | Retrieve all categories |
| GET    | /api/cities     | Retrieve all cities     |



## Event JSON Structure

Example response:

```json
{
  "id": 1,
  "title": "Concert",
  "date": "2026-05-01",
  "time": "20:00",
  "city": {
    "id": 2,
    "name": "Sarajevo"
  },
  "venue": {
    "id": 5,
    "name": "Skenderija"
  },
  "categories": [
    {
      "id": 1,
      "name": "Music"
    }
  ],
  "price": 20,
  "image": "image.jpg",
  "description": "Event description",
  "featured": true
}
```



## Controller Logic

### index

* Retrieves all events
* Supports filtering via query parameters

### show

* Returns a single event by ID
* Returns 404 Not Found if the event does not exist

### create

* Creates a new event
* Returns 201 Created on success
* Returns 422 Unprocessable Entity on validation errors

### update

* Updates an existing event
* Returns 404 Not Found if the event does not exist

### delete

* Deletes an event
* Returns 204 No Content on success
* Returns 422 Unprocessable Entity on failure



## Error Handling

Validation errors are formatted using:

```elixir
Ecto.Changeset.traverse_errors
```

Example response:

```json
{
  "errors": {
    "title": ["can't be blank"]
  }
}
```



## Categories

The categories endpoint returns a list of all available categories using a simple database query.



## Request Flow

1. Client sends an HTTP request
2. Router forwards it to the appropriate controller
3. Controller calls the business logic (context)
4. Data is formatted using JSON views
5. A JSON response is returned to the client



## Running the Project

```bash
mix deps.get
mix ecto.setup
mix phx.server
```

API will be available at:

http://localhost:4000/api



## Conclusion

EventExplorer is a modular and scalable backend system for managing events. By leveraging the Phoenix framework and RESTful design, it provides a clean separation of concerns and a solid foundation for further development.
