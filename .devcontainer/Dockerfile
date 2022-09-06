FROM rust:slim-bullseye AS stylua-builder
RUN cargo install --root=/opt/stylua --version=0.12.4 stylua

FROM mcr.microsoft.com/vscode/devcontainers/python:0-bullseye
RUN pip3 install pre-commit
COPY requirements.txt /tmp
RUN pip3 install -r /tmp/requirements.txt
RUN hererocks -l 5.1 -r 3.8.0 /usr/local
COPY rocks.txt /tmp
RUN cat /tmp/rocks.txt | xargs -n1 luarocks install
COPY --from=stylua-builder /opt/stylua /usr/local
