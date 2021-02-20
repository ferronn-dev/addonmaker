FROM python
RUN pip3 install lxml toposort pyyaml
WORKDIR /addonmaker
COPY build.py main.sh .
WORKDIR /addon
ENTRYPOINT ["sh", "/addonmaker/main.sh"]
