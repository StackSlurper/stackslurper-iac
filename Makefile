.PHONY: setup

setup:
	python3 -m venv .venv && \
	source .venv/bin/activate && \
	pip install -r requirements.txt && \
	pre-commit install
