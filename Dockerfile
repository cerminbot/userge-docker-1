# set base image (host OS)
FROM python:3.9-slim-buster

# set the working directory in the container
WORKDIR /app/

RUN echo deb http://http.us.debian.org/debian/ testing non-free contrib main > /etc/apt/sources.list \
    && dpkg-reconfigure debconf --frontend=noninteractive \
    && apt-get update

RUN apt-get install --no-install-recommends \
    curl \
    git \
    gcc \
    g++ \
    build-essential \
    gnupg2 \
    unzip \
    wget \
    ffmpeg \
    jq

# install chrome
RUN mkdir -p /tmp/ \
    && cd /tmp/ \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && dpkg -i ./google-chrome-stable_current_amd64.deb; apt-get -f install \
    && rm ./google-chrome-stable_current_amd64.deb

# install chromedriver
RUN mkdir -p /tmp/ \
    && cd /tmp/ \
    && wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip \
    && unzip /tmp/chromedriver.zip chromedriver -d /usr/bin/ \
    && rm /tmp/chromedriver.zip

ENV GOOGLE_CHROME_DRIVER /usr/bin/chromedriver
ENV GOOGLE_CHROME_BIN /usr/bin/google-chrome-stable

# install rar
RUN mkdir -p /tmp/ \
    && cd /tmp/ \
    && wget -O /tmp/rarlinux.tar.gz http://www.rarlab.com/rar/rarlinux-x64-6.0.0.tar.gz \
    && tar -xzvf rarlinux.tar.gz \
    && cd rar \
    && cp -v rar unrar /usr/bin/ \
    && rm -rf /tmp/rar*

# create a virtual environment and add it to path
ENV VIRTUAL_ENV /opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# clone the userge repo to current directory
RUN git clone https://github.com/UsergeTeam/Userge .

# upgrade pip and install extra pip modules
RUN python3 -m pip install --upgrade \
    pip \
    wheel

# install dependencies
RUN pip install -r requirements.txt

# command to run on container start
CMD [ "bash", "./run" ]