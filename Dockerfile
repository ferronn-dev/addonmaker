FROM python
WORKDIR /addonmaker
COPY packages.txt .
RUN apt-get update && apt-get -y install `cat packages.txt` && apt-get clean
COPY requirements.txt .
RUN pip3 install -r requirements.txt
RUN wget https://luarocks.org/releases/luarocks-3.5.0.tar.gz
RUN tar zxpf luarocks-3.5.0.tar.gz
RUN cd luarocks-3.5.0 && ./configure && make && make install
RUN rm -rf luarocks-3.5.0*
COPY rocks.txt .
RUN luarocks install `cat rocks.txt`
COPY build.py db.py py2lua.py main.sh testing.lua wow.lua luacheckrc.lua ./
WORKDIR /addon
ENTRYPOINT ["sh", "/addonmaker/main.sh"]
