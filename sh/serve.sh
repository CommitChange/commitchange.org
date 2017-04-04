#!/bin/bash
rerun -p '{**/*.rb}' 'bundle exec unicorn -l 4567'
