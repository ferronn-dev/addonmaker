FROM python
WORKDIR /addonmaker
COPY packages.txt .
RUN apt-get update && apt-get -y install `cat packages.txt` && apt-get clean
COPY requirements.txt .
RUN pip3 install -r requirements.txt
RUN wget https://github.com/ninja-build/ninja/releases/download/v1.10.2/ninja-linux.zip
RUN unzip ninja-linux.zip && mv ninja /usr/local/bin && rm ninja-linux.zip
RUN wget https://luarocks.org/releases/luarocks-3.5.0.tar.gz
RUN tar zxpf luarocks-3.5.0.tar.gz
RUN cd luarocks-3.5.0 && ./configure && make && make install
RUN rm -rf luarocks-3.5.0*
COPY rocks.txt .
RUN luarocks install `cat rocks.txt`
COPY *.lua *.py *.sh creds.json ./
RUN luacheck *.lua
WORKDIR /addon
ENTRYPOINT ["sh", "/addonmaker/main.sh"]
