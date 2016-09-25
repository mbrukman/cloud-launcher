[![Build Status](https://travis-ci.org/mbrukman/cloud-launcher.svg?branch=master)](https://travis-ci.org/mbrukman/cloud-launcher)

# Cloud Launcher

Simplifying the process of launching applications on [Google Cloud Platform](https://cloud.google.com/).

## Global setup

Install the [Google APIs Client Library for Python](https://developers.google.com/api-client-library/python/).

## Per-project setup

This is a one-time setup for each Google Cloud Platform project you want to use
with Cloud Launcher.

* Modify [`src/settings.sh`](src/settings.sh) to specify a Google Cloud Platform
  project you have access to that has GCE enabled.

* Create a directory to store your credentials and set appropriate permissions:

  ```bash
  mkdir -m 700 -p "$HOME/cloud/projects/$PROJECT"
  ```

* Open [Google Cloud developer console](https://cloud.google.com/console)

* Go to your Google Cloud Platform project

  * Click on your project name
  * Click on _"APIs & Auth"_
  * Click on _"Credentials"_
  * Under _"OAuth"_, click on _"Create a new Client ID"_
    * Choose _"Installed application"_
    * Application type is _"other"_
    * Click on _"Create Client ID"_
  * Under the new section _"Client ID for native application"_, click on
    _"Download JSON"_
  * Save this file as `$HOME/cloud/projects/$PROJECT/client_secrets.json`

* Now you can launch applications! Try one of the [examples](examples/README.md)
  or look at the [app catalog](apps/README.md).

## Discuss

You can discuss Cloud Launcher with other users and developers via the mailing
list [cloud-launcher (at) googlegroups.com](https://groups.google.com/group/cloud-launcher).

## License

Apache 2.0; see [LICENSE.txt](LICENSE.txt) for details.

## Disclaimer

This project is not an official Google project. It is not supported by Google
and Google specifically disclaims all warranties as to its quality,
merchantability, or fitness for a particular purpose.
