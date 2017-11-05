.PHONY: init build test clean docs

init:
	pip install -r requirements/dev.txt
	python setup.py sdist
	pip install -e .
	make test

build:
	TINEX_USE_CYTHON=true python setup.py build_ext --inplace

test: build
	pytest

tox:
	detox

coverage: build
	pytest --cov=tinex --cov-report html --cov-report term --cov-branch

clean:
	$(RM) -r *.so *.c *.pyc __pycache__ *.egg-info build dist
	find . | grep -E "(__pycache__|\.pyc|\.pyo$$)" | xargs rm -rf
	python setup.py clean --all

publish: clean
	python setup.py sdist
	twine upload dist/*.tar.gz

docs: build
	@touch docs/api.rst  # ensure api docs always rebuilt
	make -C docs/ html
