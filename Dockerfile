FROM python:3.8.1

ARG work_dir=/usr/local/work/

ADD . $work_dir

WORKDIR $work_dir

RUN pip install --upgrade pip && \
    pip install pipenv && \
    pipenv install --system