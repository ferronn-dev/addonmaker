FROM python
WORKDIR /addonmaker
COPY packages.txt .
RUN apt-get update && apt-get -y install `cat packages.txt` && apt-get clean
COPY requirements.txt .
RUN pip3 install -r requirements.txt
COPY build.py main.sh testing.lua wow.lua .
WORKDIR /addon
ENTRYPOINT ["sh", "/addonmaker/main.sh"]
