.PHONY: init build test clean docs

init:
	pip install -r requirements.txt

build:
	python setup.py build_ext --inplace

test: build
	pytest

clean:
	rm -rf build
	find . | grep -E "(__pycache__|\.pyc|\.pyo$$)" | xargs rm -rf
	python setup.py clean --all

docs: build
	@touch docs/api.rst  # ensure api docs always rebuilt
	make -C docs/ html
