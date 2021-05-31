FROM python:3.9.5-slim AS base

FROM base AS builder

ENV PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  POETRY_NO_INTERACTION=1 \
  POETRY_VIRTUALENVS_CREATE=false \
  PATH="$PATH:/runtime/bin" \
  PYTHONPATH="$PYTHONPATH:/runtime/lib/python3.9/site-packages" \
  # Versions:
  POETRY_VERSION=1.1.5

# System deps:
RUN apt-get update && apt-get install -y build-essential unzip wget python-dev
RUN pip install "poetry==$POETRY_VERSION"


# Copy only requirements to cache them in docker layer
WORKDIR /simple_web_app

COPY poetry.lock pyproject.toml /simple_web_app/

RUN poetry export --dev --without-hashes --no-interaction --no-ansi -f requirements.txt -o requirements.txt
RUN pip install --prefix=/runtime --force-reinstall -r requirements.txt

# Project initialization:
# RUN poetry config virtualenvs.create false \
#   && poetry install $(test "$APP_ENV" == production && echo "--no-dev") --no-interaction --no-ansi
COPY . /simple_web_app

FROM base AS runtime
COPY --from=builder /runtime /usr/local

COPY . /simple_web_app

WORKDIR /simple_web_app
# Creating folders, and files for a project:
RUN apt-get update && apt-get install -f -y postgresql-client

# CMD ["/bin/bash"]
CMD ["python", "simple_web_app/app.py"]
