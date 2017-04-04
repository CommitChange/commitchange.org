#!/bin/bash

RACK_ENV=test DATABASE_URL=postgres://admin:password@localhost/commitchange_test bundle exec ruby test/app.rb -p "$@"
