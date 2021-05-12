FROM python
WORKDIR /addonmaker
COPY packages.txt ./
RUN apt-get update && apt-get -y install `cat packages.txt` && apt-get clean
RUN pip3 install pipenv
COPY Pipfile Pipfile.lock ./
RUN pipenv install --system --deploy --ignore-pipfile
RUN wget https://github.com/ninja-build/ninja/releases/download/v1.10.2/ninja-linux.zip
RUN unzip ninja-linux.zip && mv ninja /usr/local/bin && rm ninja-linux.zip
RUN wget https://luarocks.org/releases/luarocks-3.5.0.tar.gz
RUN tar zxpf luarocks-3.5.0.tar.gz
RUN cd luarocks-3.5.0 && ./configure && make && make install
RUN rm -rf luarocks-3.5.0*
COPY rocks.txt ./
RUN cat rocks.txt | xargs -n1 luarocks install
RUN wget https://github.com/cli/cli/releases/download/v1.9.2/gh_1.9.2_linux_amd64.deb
RUN apt install ./gh_1.9.2_linux_amd64.deb
COPY *.lua *.py *.sh creds.json .pylintrc ./
RUN lua5.1 gencheck.lua > luacheckrc.lua
RUN luacheck *.lua && pylint *.py
WORKDIR /addon
ENTRYPOINT ["sh", "/addonmaker/main.sh"]
