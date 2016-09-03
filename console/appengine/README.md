# Overview

This directory contains a Google App Engine app which provides a basic
implementation of a cloud console, similar in spirit  to [Google Cloud
Console](https://console.cloud.google.com).

As this is a work-in-progress, much of the functionality is missing, so this app
does not provide a full replacement for Google Cloud Console.

Currently-implemented features:

**Google Compute Engine**

* list of VM instances
* SSH to a given instance
* view serial port output of a given instance
* start / stop / delete of a single instance or selection of instances

For detailed instructions for how to run the Console locally or on Google App
Engine, see [docs/setup.md](docs/setup.md).
