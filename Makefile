.PHONY: test clean docs build

test: build
	pytest

clean:
	rm -rf build
	find . | grep -E "(__pycache__|\.pyc|\.pyo$$)" | xargs rm -rf
	python setup.py clean --all

docs: build
	@touch docs/api.rst  # ensure api docs always rebuilt
	make -C docs/ html

build:
	python setup.py build_ext --inplace
