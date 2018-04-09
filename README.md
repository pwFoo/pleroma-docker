# Pleroma-Docker

[Pleroma](https://pleroma.social/) is a selfhosted social network that uses OStatus/ActivityPub.

This repository is my attempt to dockerize it for easier deployment.

## Features

- 100% generic
- Everything is customizable
- Everything is configurable through `.env` files
- Zero special host dependencies
- "It just works"

## Assumptions

This repo assumes that you're using [Træfik](https://traefik.io/) as your auto-configuring reverse proxy.

## Tutorial

- Make sure that `m4` and `docker-compose` are installed
- Check out this repo
- Create your env file (`cp .env.dist .env`)
- Edit the env values
- Run `./pleroma build`
- Run `./pleroma run`
- ...
- Profit!

## Building an image

Since this setup injects code into pleroma that moves it's configuration into the environment (ref ["The Twelve-Factor App"](https://12factor.net/)), the image is 100% reusable and can be shared/replicated across multiple hosts. To do that just run `./pleroma build` as usual and then tag your image to whatever you want. Just make sure to start the container with `env_file:` or all required `-e` pairs.

## Customizing Pleroma

Just add your customizations (and their folder structure) to `custom.d`.<br>
They will be copied into the right place when the container starts.<br>
You can even replace/patch pleroma's code with this, because the project is recompiled at startup.

In general: Prepending `custom.d` to pleroma's customization guides should work all the time.<br>
Check them out in the [official pleroma wiki](https://git.pleroma.social/pleroma/pleroma/wikis/home).

Here are a few customization examples:

- I want to have a custom thumbnail
    - Save it in `custom.d/priv/static/instance/thumbnail.jpeg`

- I want to change the `config.json`.
    - Just modify [the template](https://git.pleroma.social/pleroma/pleroma/blob/develop/priv/static/static/config.json) and save it in `custom.d/priv/static/static/config.json`

- I want to change the background
    - Throw an image into `custom.d/priv/static/static` and then edit the config from above

- I want a custom logo
    - See above

- I need blobs. Give me emojis.
    - Save them in `custom.d/priv/static/emoji`. Then create and/or edit `custom.d/config/custom_emoji.txt`.

- I want custom ToS
    - Throw a HTML document to `custom.d/priv/static/static/terms-of-service.html`

You get the gist.<br>
Pretty basic stuff.
