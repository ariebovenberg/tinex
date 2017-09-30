.PHONY: test clean docs

test:
	python setup.py build_ext --inplace
	pytest

clean:
	rm -rf build
	find . | grep -E "(__pycache__|\.pyc|\.pyo$$)" | xargs rm -rf
	python setup.py clean --all

docs:
	make -C docs/ html
