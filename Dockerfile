FROM python
RUN pip3 install lxml toposort pyyaml
WORKDIR /addonmaker
COPY build.py .
WORKDIR /addon
ENTRYPOINT ["python3", "/addonmaker/build.py"]
