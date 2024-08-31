FROM docker.io/bitwalker/alpine-elixir-phoenix:1.14

ARG CLIENT_URL=http://localhost:4000
ARG SERVER_URL=http://localhost:3000

ENV MIX_ENV=prod
ENV CLIENT_URL=${CLIENT_URL}
ENV SERVER_URL=${CLIENT_URL}

ADD mix.exs mix.lock ./

RUN mix deps.get
RUN mix deps.compile

ADD . .

RUN mix compile

USER default

CMD ["mix", "phx.server"]
