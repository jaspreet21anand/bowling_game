# BOWLING GAME

This repository opens up API for
- starting a new bowling game which returns `game_id`
- recording ball throws with `pinfall_count` and `game_id` as parameters
- api to return current game `state` and `score`

* Ruby version - ruby-2.6.3

* Configuration - Rails 6.0.2 --api --postgresql

* configure your database.yml for postgresql
  rake db:create
  rake db:migrate

* Enpoints:
1. Start New Game - `POST /games`
- `{ "status": "success", "message": "New game started", "game_id": 37 }`
2. Add a Throw - `POST /games/:game_id/throws`
- `{ "status": "success", "message": "Throw recorded successfully.", "knocked_pins": 1 }`
3. Get Game Score & Status - `GET /games/:id`
- ```{
    "status": "success",
    "game": {
        "state": "open",
        "score": 6,
        "score_details": {
            "frames": [
                {
                    "score": 6,
                    "state": "closed",
                    "throws": [
                        {
                            "knocked_pins": 1,
                            "knock_type": "play"
                        },
                        {
                            "knocked_pins": 5,
                            "knock_type": "play"
                        }
                    ]
                },
                {
                    "score": null,
                    "state": "closed",
                    "throws": [
                        {
                            "knocked_pins": 5,
                            "knock_type": "play"
                        },
                        {
                            "knocked_pins": 5,
                            "knock_type": "spare"
                        }
                    ]
                }
            ]
        }
    }
  }```