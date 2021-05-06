# HnAggregator

A simple Hacker News aggregator

## About

This is a demo project for educational purposes.

Implements a basic phoenix app that fetches data from the Hacker News API for further analysis or consumption.

"Every configurable interval of time", a background process fetch the top N stories from HN and save the data into an ETS used as Repo.

Serve the data via Json HTTP rest API and Json over WebSocket

## Running
There is a docker-compose to run a docker image with a release of the application
```
docker-compose up --build
```
running the compose the server will listen on localhost:4000, the host and port are configurables from docker-compose.

Or you can simply run the server
```
mix phx.server
```

## HTTP API

You can GET the data via HTTP

```
GET /api/stories
```
List all stories stored in the repo, accept query params for pagination and limits as **page=1&limit=3** (default limit=10)

For example to list the first 3 stories :
localhost:4000/api/stories?page=1&limit=3
```
{
    "stories": [
        {
            "by": "aracena",
            "descendants": 20,
            "id": 27056008,
            "kids": [
                ...
            ],
            "score": 49,
            "time": 1620249864,
            "title": "As Amazon deforestation hits 12 year high, France rejects Brazilian soy",
            "type": "story",
            "url": "https://news.mongabay.com/2020/12/as-amazon-deforestation-hits-12-year-high-france-rejects-brazilian-soy/"
        },
        {
            "by": "orblivion",
            "descendants": 4,
            "id": 27055663,
            "kids": [
                ...
            ],
            "score": 40,
            "time": 1620247961,
            "title": "Indonesia coral reef partially restored in extensive project",
            "type": "story",
            "url": "https://www.bbc.com/news/av/science-environment-56985594"
        },
        {
            "by": "andredz",
            "descendants": 77,
            "id": 27052840,
            "kids": [
                ...
            ],
            "score": 331,
            "time": 1620235543,
            "title": "Send: A Fork of Mozilla's Firefox Send",
            "type": "story",
            "url": "https://github.com/timvisee/send"
        }
    ]
}
```
Also you can get one story with
```
GET /api/stories/id
```
for example
http://localhost:4000/api/stories/1
```
{
   "by": "aracena",
   "descendants": 20,
   "id": 27056008,
   "kids": [
       ...
   ],
   "score": 49,
   "time": 1620249864,
   "title": "As Amazon deforestation hits 12 year high, France rejects Brazilian soy",
   "type": "story",
   "url": "https://news.mongabay.com/2020/12/as-amazon-deforestation-hits-12-year-high-france-rejects-brazilian-soy/"
}
```
NOTE: The IDs are implemented to match with the ids shown in HN page (https://news.ycombinator.com/) to easily testing

## WEB SOCKET API
- Upon conection server sends all stories stored in the repo in that moment

- Every time that the stories are poolled, the server will sent the new stories to the socket

In order to get data via WebSocket you have 2 options

**1 - Using Phoenix channels.**
You can subscribe to topic stories:feed in ws://localhost:4000/socket

**2 - Simple WebSocket**
You can connect to a basic web socket in ws://localhost:4000/ws/stories


### Git hooks
There is a githook to check and force to you to run `mix format` in order to maintain readability and consistency in the code

To configure run the following command after cloning the repository:

```bash
git config --local core.hooksPath .githooks/
```

