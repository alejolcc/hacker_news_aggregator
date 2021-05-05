#
# Builder docker image
#

FROM elixir:1.11-alpine AS builder

# The following are build arguments used to change variable parts of the image.
# The name of your application/release (required)
ARG APP_NAME
ARG SECRET_KEY_BASE

ENV APP_NAME=${APP_NAME}
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

# set build ENV
ENV MIX_ENV=prod

# By convention, /opt is typically used for applications
WORKDIR /opt/app

# This step installs all the build tools we'll need
RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
    git \
    build-base \
    nodejs \
    nodejs-npm && \
  mix local.rebar --force && \
  mix local.hex --force

# This copies our app source code into the build container
COPY . .

# Run the build
RUN mix do deps.get, deps.compile, clean, compile

# Install phoenix npm modules
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# Run the release
WORKDIR /opt/app
RUN \
  mkdir -p /opt/built && \
  mix release && \
  mv _build/prod/rel/${APP_NAME}/* /opt/built

#
# Production docker image
#

# From this line onwards, we're in a new image, which will be the image used in production
FROM elixir:1.11-alpine

# The name of your application/release
ARG APP_NAME

# Set the workdir and copy the released app from the builder container into the production container.
WORKDIR /opt/${APP_NAME}
COPY --from=builder /opt/built .

# Copy the docker entrypoint which is not part of the app release into the production container.
COPY --from=builder /opt/app/docker/entrypoint.sh .
RUN chmod +x ./entrypoint.sh

# We need to set these environment variables because the entrypoint script uses them.
ENV APP_NAME=${APP_NAME}

# Launch the app
ENTRYPOINT ["./entrypoint.sh"]
