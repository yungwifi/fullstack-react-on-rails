#!/bin/bash

APPNAME=${1?Error: no name given}

cd ../../

rails new $APPNAME --api -d postgresql

cd $APPNAME

gem install foreman

git init

create-react-app client

cd client 

echo '{
  "name": "client",
  "version": "0.1.0",
  "private": true,
  "proxy": "http://localhost:3001",
  "dependencies": {
    "react": "^16.4.0",
    "react-dom": "^16.4.0",
    "react-scripts": "1.1.4"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test --env=jsdom",
    "eject": "react-scripts eject"
  }
}' > package.json 

cd ..

gem install foreman

touch Procfile.dev

echo "web: sh -c 'cd client && PORT=3000 npm start'
api: rails s -p 3001" > Procfile.dev

touch Procfile

echo "web: rails s" > Procfile

echo '
{
    "name": "'$APPNAME'",
    "engines": {
        "node": "10.13.0"
    },
    "scripts": {
        "build": "cd client && npm install && npm run build && cd ..",
        "deploy": "cp -a client/build/. public/",
        "postinstall": "npm run build && npm run deploy"
    }
}' > package.json

rails g model App name 

rails db:drop db:create db:migrate

heroku create $APPNAME

heroku buildpacks:add --index 1 heroku/ruby
heroku buildpacks:add --index 2 heroku/nodejs

heroku addons:create heroku-postgresql:hobby-dev

git add -A 

git commit -m "Heroku Push"

git push heroku master 
