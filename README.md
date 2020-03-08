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