FROM ghcr.io/gleam-lang/gleam:v1.9.1-erlang-alpine

#todo add in frountend building here

# Add project code
COPY . /build/

# Compile the project
RUN cd /build/backend \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment /app \
  && rm -r /build

# Run the server
EXPOSE 3000
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
