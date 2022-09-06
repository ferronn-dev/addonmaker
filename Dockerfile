FROM python:3.7.10-buster
WORKDIR /addonmaker
COPY requirements.txt .
RUN pip3 install -r requirements.txt
RUN git clone -b v1.10.2 --depth 1 https://github.com/ninja-build/ninja
RUN cd ninja && ./configure.py --bootstrap && cp ninja /usr/local/bin
RUN rm -rf ninja
RUN hererocks -l 5.1 -r 3.8.0 /usr/local
COPY rocks.txt .
RUN cat rocks.txt | xargs -n1 luarocks install
ARG TARGETOS
ARG TARGETARCH
RUN wget https://github.com/cli/cli/releases/download/v1.14.0/gh_1.14.0_${TARGETOS}_${TARGETARCH}.deb
RUN apt install ./gh_1.14.0_${TARGETOS}_${TARGETARCH}.deb
COPY *.lua *.py *.sh creds.json .pylintrc ./
RUN lua gencheck.lua > luacheckrc.lua
#RUN luacheck *.lua && pylint *.py
WORKDIR /addon
ENTRYPOINT ["sh", "/addonmaker/main.sh"]
