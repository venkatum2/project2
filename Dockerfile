FROM node:latest as buildstage

WORKDIR /app

COPY package.json ./

RUN npm install

COPY . ./

RUN npm install -g ionic cordova
RUN ionic build --prod

FROM nginx:alpine

COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /usr/share/nginx/html

COPY --from=buildstage /app/www .

