# Minikube Travis Examples

This repository contains examples for running kubernetes CI tests on top of minikube.  There is an accompanying blog post here for reference.  The goal of this repository is to help users use minikube in CI as well as collect information, examples, and best practices for doing so.

## Getting Started

This repository has two examples of writing tests for kubernetes applications using minikube on top of Travis CI.  The two examples applications are a hello world node app, "hellonode" and a redis/php "guestbook" app.

## Running the tests

The examples can be run locally on linux machines using the [hellonode/guestbook]-travis.sh.  The hellonode example is designed to be a starting template for your own testing.  Look at the hellonode/hellonode-travis.yml or the .travis.yml files in this repository.

## Contributing

Feel free to add your own examples or leave issues that you are having with the examples in this repo.